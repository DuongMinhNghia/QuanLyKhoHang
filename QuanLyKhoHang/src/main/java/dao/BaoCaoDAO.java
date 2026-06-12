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

    // 1. Lọc Báo Cáo NHẬP KHO
    public List<PhieuNhapDTO> getBaoCaoNhapKho(String filter) {
        List<PhieuNhapDTO> list = new ArrayList<>();
        String sql = "SELECT pn.MaPhieu, pn.NgayLap, ncc.TenNCC, hh.TenHang, ct.SoLuong, ct.DonGia, pn.MaNguoiDuyet "
                   + "FROM PhieuNhapKho pn "
                   + "JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC "
                   + "JOIN ChiTietPhieuNhapKho ct ON pn.MaPhieu = ct.MaPhieu "
                   + "JOIN HangHoa hh ON ct.MaHang = hh.MaHang WHERE 1=1 ";
        
        if ("daduyet".equals(filter)) sql += "AND pn.MaNguoiDuyet IS NOT NULL ";
        else if ("choduyet".equals(filter)) sql += "AND pn.MaNguoiDuyet IS NULL ";
        
        sql += "ORDER BY pn.NgayLap DESC";

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new PhieuNhapDTO(rs.getString("MaPhieu"), rs.getDate("NgayLap"), rs.getString("TenNCC"), 
                                              rs.getString("TenHang"), rs.getInt("SoLuong"), rs.getDouble("DonGia"), rs.getString("MaNguoiDuyet")));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 2. Lọc Báo Cáo XUẤT KHO
    public List<PhieuXuatDTO> getBaoCaoXuatKho(String filter) {
        List<PhieuXuatDTO> list = new ArrayList<>();
        String sql = "SELECT px.MaPhieu, px.NgayLap, hh.TenHang, ct.SoLuong, ct.DonGia, px.MaNguoiDuyet "
                   + "FROM PhieuXuatKho px "
                   + "JOIN ChiTietPhieuXuatKho ct ON px.MaPhieu = ct.MaPhieu "
                   + "JOIN HangHoa hh ON ct.MaHang = hh.MaHang WHERE 1=1 ";
        
        if ("daduyet".equals(filter)) sql += "AND px.MaNguoiDuyet IS NOT NULL ";
        else if ("choduyet".equals(filter)) sql += "AND px.MaNguoiDuyet IS NULL ";
        
        sql += "ORDER BY px.NgayLap DESC";

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new PhieuXuatDTO(rs.getString("MaPhieu"), rs.getDate("NgayLap"), rs.getString("TenHang"), 
                                              rs.getInt("SoLuong"), rs.getDouble("DonGia"), rs.getString("MaNguoiDuyet")));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 3. Lọc Báo Cáo KIỂM KÊ (Tính toán lại Lý thuyết = Thực tế - Chênh lệch)
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