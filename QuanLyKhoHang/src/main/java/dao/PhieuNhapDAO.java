package dao;

import model.NhaCungCap;
import model.PhieuNhapKho;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PhieuNhapDAO {

    // ==============================================================================
    // 1. LẤY DANH SÁCH NHÀ CUNG CẤP 
    // Hàm này nhận Connection từ Servlet truyền vào để tái sử dụng kết nối
    // ==============================================================================
    public List<NhaCungCap> getAllNhaCungCap(Connection conn) {
        List<NhaCungCap> list = new ArrayList<>();
        String sql = "SELECT MaNCC, TenNCC FROM NhaCungCap";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new NhaCungCap(rs.getString("MaNCC"), rs.getString("TenNCC")));
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    // ==============================================================================
    // 2.TỰ MỞ TỰ ĐÓNG KẾT NỐI (BACKWARD COMPATIBILITY)
    // ==============================================================================
    public List<NhaCungCap> getAllNhaCungCap() {
        List<NhaCungCap> list = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection()) {
            list = getAllNhaCungCap(conn);
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    // ==============================================================================
    // 3. LƯU PHIẾU NHẬP VÀ CHI TIẾT (DÙNG TRANSACTION)
    // ==============================================================================
    public String luuPhieuNhapMoi(PhieuNhapKho pn, String tenDangNhapThuKho, String[] maHangArr, String[] soLuongArr, String[] donGiaArr) {
        Connection conn = null;
        try {
            // Dùng DBConnect
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // Bước 1: Lưu thông tin phiếu (MaNguoiDuyet = NULL để chờ duyệt)
            String sqlPhieu = "INSERT INTO PhieuNhapKho (MaPhieu, NgayLap, MaNV, MaNCC, SoHoaDon, GhiChu, MaNguoiDuyet) "
                            + "VALUES (?, ?, (SELECT MaNV FROM TaiKhoan WHERE TenDangNhap = ?), ?, ?, ?, NULL)";
            try (PreparedStatement ps = conn.prepareStatement(sqlPhieu)) {
                ps.setString(1, pn.getMaPhieu());
                ps.setDate(2, pn.getNgayLap());
                ps.setString(3, tenDangNhapThuKho);
                ps.setString(4, pn.getMaNCC());
                ps.setString(5, pn.getSoHoaDon());
                ps.setString(6, pn.getGhiChu());
                ps.executeUpdate();
            }

            // Bước 2: Lưu các mặt hàng 
            String sqlChiTiet = "INSERT INTO ChiTietPhieuNhapKho (MaPhieu, MaHang, SoLuong, DonGia) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlChiTiet)) {
                for (int i = 0; i < maHangArr.length; i++) {
                    ps.setString(1, pn.getMaPhieu());
                    ps.setString(2, maHangArr[i]);
                    ps.setInt(3, Integer.parseInt(soLuongArr[i]));
                    ps.setDouble(4, Double.parseDouble(donGiaArr[i]));
                    ps.executeUpdate(); 
                }
            }

            conn.commit();
            return "SUCCESS";

        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
            return "Lỗi CSDL: " + e.getMessage();
        } catch (Exception e) {
            return "Lỗi hệ thống: " + e.getMessage();
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (Exception e) {}
        }
    }

    // ==============================================================================
    // 4. LẤY DANH SÁCH PHIẾU NHẬP 
    // ==============================================================================
    public List<model.PhieuNhapDTO> getDanhSachPhieuNhap(String tuKhoa) {
        List<model.PhieuNhapDTO> list = new ArrayList<>();
        String sql = "SELECT pn.MaPhieu, pn.NgayLap, ncc.TenNCC, hh.TenHang, ct.SoLuong, ct.DonGia, pn.MaNguoiDuyet, pn.GhiChu "
                   + "FROM PhieuNhapKho pn "
                   + "JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC "
                   + "JOIN ChiTietPhieuNhapKho ct ON pn.MaPhieu = ct.MaPhieu "
                   + "JOIN HangHoa hh ON ct.MaHang = hh.MaHang ";
        
        if (tuKhoa != null && !tuKhoa.trim().isEmpty()) {
            sql += "WHERE hh.TenHang LIKE ? OR pn.MaPhieu LIKE ? ";
        }
        
        sql += "ORDER BY pn.NgayLap DESC, pn.MaPhieu DESC";

        try {
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                
                if (tuKhoa != null && !tuKhoa.trim().isEmpty()) {
                    ps.setString(1, "%" + tuKhoa + "%");
                    ps.setString(2, "%" + tuKhoa + "%");
                }
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        model.PhieuNhapDTO dto = new model.PhieuNhapDTO(
                            rs.getString("MaPhieu"),
                            rs.getDate("NgayLap"),
                            rs.getString("TenNCC"),
                            rs.getString("TenHang"),
                            rs.getInt("SoLuong"),
                            rs.getDouble("DonGia"),
                            rs.getString("MaNguoiDuyet"),
                            rs.getString("GhiChu") 
                        );
                        list.add(dto);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // ==============================================================================
    // 5. DUYỆT PHIẾU NHẬP
    // ==============================================================================
    public void duyetPhieu(String maPhieu, String tenDangNhapNguoiDuyet) {
        // Cập nhật MaNguoiDuyet bằng MaNV của tài khoản đang đăng nhập
        String sql = "UPDATE PhieuNhapKho SET MaNguoiDuyet = (SELECT MaNV FROM TaiKhoan WHERE TenDangNhap = ?) WHERE MaPhieu = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tenDangNhapNguoiDuyet);
            ps.setString(2, maPhieu);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==============================================================================
    // 6. TỪ CHỐI PHIẾU NHẬP
    // ==============================================================================
    public void tuChoiPhieu(String maPhieu, String tenDangNhapNguoiDuyet, String ghiChu) {
        // Vừa cập nhật người duyệt, vừa ghi đè cột GhiChu bằng lý do từ chối
        String sql = "UPDATE PhieuNhapKho SET MaNguoiDuyet = (SELECT MaNV FROM TaiKhoan WHERE TenDangNhap = ?), GhiChu = ? WHERE MaPhieu = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tenDangNhapNguoiDuyet);
            ps.setString(2, ghiChu);
            ps.setString(3, maPhieu);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}