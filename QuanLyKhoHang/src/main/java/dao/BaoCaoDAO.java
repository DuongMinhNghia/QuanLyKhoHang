package dao;

import model.PhieuNhapDTO;
import model.PhieuXuatDTO;
import model.KiemKeDTO;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class BaoCaoDAO {
    private static final String DB_URL = "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=QuanLyKhoHang;encrypt=false";
    private static final String DB_USER = "sa"; 
    private static final String DB_PASS = "123"; 

    // 1. LỌC BÁO CÁO NHẬP KHO
    public List<PhieuNhapDTO> getBaoCaoNhapKho(String filter) {
        List<PhieuNhapDTO> list = new ArrayList<>();

        String sql = "SELECT p.MaPhieu, p.NgayLap, n.TenNCC, h.TenHang, c.SoLuong, c.DonGia, p.MaNguoiDuyet, p.GhiChu "
                   + "FROM PhieuNhapKho p "
                   + "JOIN ChiTietPhieuNhapKho c ON p.MaPhieu = c.MaPhieu "
                   + "JOIN NhaCungCap n ON p.MaNCC = n.MaNCC "
                   + "JOIN HangHoa h ON c.MaHang = h.MaHang "
                   + "WHERE 1=1 ";

        // NỐI CHUỖI LỌC DỮ LIỆU TỪ DROPDOWN
        if ("daduyet".equals(filter)) {
            sql += "AND p.MaNguoiDuyet IS NOT NULL AND (p.GhiChu IS NULL OR p.GhiChu NOT LIKE N'Từ chối:%') ";
        } else if ("choduyet".equals(filter)) {
            sql += "AND p.MaNguoiDuyet IS NULL AND (p.GhiChu IS NULL OR p.GhiChu NOT LIKE N'Từ chối:%') ";
        } else if ("tuchoi".equals(filter)) {
            sql += "AND p.GhiChu LIKE N'Từ chối:%' ";
        }

        sql += "ORDER BY p.MaPhieu DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                PhieuNhapDTO dto = new PhieuNhapDTO();
                dto.setMaPhieu(rs.getString("MaPhieu"));
                dto.setNgayLap(rs.getDate("NgayLap"));
                dto.setTenNCC(rs.getString("TenNCC"));
                dto.setTenHang(rs.getString("TenHang"));
                dto.setSoLuong(rs.getInt("SoLuong"));
                dto.setDonGia(rs.getDouble("DonGia"));
                dto.setMaNguoiDuyet(rs.getString("MaNguoiDuyet"));
                dto.setGhiChu(rs.getString("GhiChu"));
                
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. LỌC BÁO CÁO XUẤT KHO
    public List<PhieuXuatDTO> getBaoCaoXuatKho(String filter) {
        List<PhieuXuatDTO> list = new ArrayList<>();
        
        String sql = "SELECT p.MaPhieu, p.NgayLap, p.BoPhanNhan, h.TenHang, c.SoLuong, c.DonGia, p.MaNguoiDuyet, p.MucDich "
                   + "FROM PhieuXuatKho p "
                   + "JOIN ChiTietPhieuXuatKho c ON p.MaPhieu = c.MaPhieu "
                   + "JOIN HangHoa h ON c.MaHang = h.MaHang "
                   + "WHERE 1=1 ";

        // LỌC DỮ LIỆU TỪ DROPDOWN (Bao gồm cả TỪ CHỐI)
        if ("daduyet".equals(filter)) {
            sql += "AND p.MaNguoiDuyet IS NOT NULL AND (p.MucDich IS NULL OR p.MucDich NOT LIKE N'Từ chối:%') ";
        } else if ("choduyet".equals(filter)) {
            sql += "AND p.MaNguoiDuyet IS NULL AND (p.MucDich IS NULL OR p.MucDich NOT LIKE N'Từ chối:%') ";
        } else if ("tuchoi".equals(filter)) {
            sql += "AND p.MucDich LIKE N'Từ chối:%' ";
        }

        sql += "ORDER BY p.MaPhieu DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                PhieuXuatDTO dto = new PhieuXuatDTO();
                dto.setMaPhieu(rs.getString("MaPhieu"));
                dto.setNgayLap(rs.getDate("NgayLap")); // Chắc chắn rằng DTO đang là kiểu Date nhé
                dto.setBoPhanNhan(rs.getString("BoPhanNhan"));
                dto.setTenHang(rs.getString("TenHang"));
                dto.setSoLuong(rs.getInt("SoLuong"));
                dto.setDonGia(rs.getDouble("DonGia"));
                dto.setMaNguoiDuyet(rs.getString("MaNguoiDuyet"));
                dto.setMucDich(rs.getString("MucDich"));
                
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Lọc Báo Cáo KIỂM KÊ
    public List<KiemKeDTO> getBaoCaoKiemKe(String filter) {
        List<KiemKeDTO> list = new ArrayList<>();
        String sql = "SELECT pk.MaKiemKe, pk.NgayKiem, hh.TenHang, "
                   + "(ct.SoLuongThucTe - ct.ChenhLech) AS LyThuyet, "
                   + "ct.SoLuongThucTe, ct.ChenhLech, ct.NguyenNhan "
                   + "FROM PhieuKiemKeHangHoa pk "
                   + "JOIN ChiTietPhieuKiemKe ct ON pk.MaKiemKe = ct.MaKiemKe "
                   + "JOIN HangHoa hh ON ct.MaHang = hh.MaHang WHERE 1=1 ";
        
        // Lọc theo yêu cầu của bạn: Khớp (bình thường) hoặc Lệch (có chỉnh sửa)
        if ("lech".equals(filter)) sql += "AND ct.ChenhLech <> 0 ";
        else if ("khop".equals(filter)) sql += "AND ct.ChenhLech = 0 ";
        
        sql += "ORDER BY pk.NgayKiem DESC";

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new KiemKeDTO(rs.getString("MaKiemKe"), rs.getDate("NgayKiem"), rs.getString("TenHang"), 
                                           rs.getInt("LyThuyet"), rs.getInt("SoLuongThucTe"), rs.getInt("ChenhLech"), rs.getString("NguyenNhan")));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}