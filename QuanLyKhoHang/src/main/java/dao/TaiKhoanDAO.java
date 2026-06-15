package dao;

import model.taikhoan;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class TaiKhoanDAO {
    // SỬA LẠI 3 DÒNG NÀY CHO KHỚP VỚI SQL SERVER CỦA BẠN
    private static final String DB_URL = "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=QuanLyKhoHang;encrypt=false";
    private static final String DB_USER = "sa"; 
    private static final String DB_PASS = "123"; 

 public taikhoan checkLogin(String username, String password) {
    // Đảm bảo SQL lấy ra cả cột TrangThai
    String sql = "SELECT t.TenDangNhap, t.MatKhau, t.VaiTro, t.TrangThai, n.HoTen " +
                 "FROM TaiKhoan t LEFT JOIN NhanVien n ON t.MaNV = n.MaNV " +
                 "WHERE t.TenDangNhap = ? AND t.MatKhau = ?";
                 
    try (Connection conn = DBConnect.getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
         
        ps.setString(1, username);
        ps.setString(2, password);
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                taikhoan acc = new taikhoan();
                acc.setTenDangNhap(rs.getString("TenDangNhap"));
                acc.setVaiTro(rs.getString("VaiTro"));
                acc.setHoTen(rs.getString("HoTen"));
                // THÊM DÒNG NÀY ĐỂ LẤY TRẠNG THÁI TỪ DB
                acc.setTrangThai(rs.getString("TrangThai")); 
                
                return acc;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}
 
}