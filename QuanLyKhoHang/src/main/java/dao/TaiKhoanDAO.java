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

    public taikhoan checkLogin(String tenDangNhap, String matKhau) {
        taikhoan taikhoan = null;
        
        // Câu lệnh SQL JOIN 2 bảng để lấy Họ Tên và Vai Trò
        String query = "SELECT T.TenDangNhap, T.VaiTro, N.HoTen " +
                       "FROM TaiKhoan T " +
                       "JOIN NhanVien N ON T.MaNV = N.MaNV " +
                       "WHERE T.TenDangNhap = ? AND T.MatKhau = ?";

        try {
            // Khai báo Driver SQL Server
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            // Mở kết nối
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement(query)) {
                 
                ps.setString(1, tenDangNhap);
                ps.setString(2, matKhau);
                
                // Thực thi câu lệnh
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String user = rs.getString("TenDangNhap");
                        String role = rs.getString("VaiTro");
                        String name = rs.getString("HoTen");
                        
                        // Nếu có dữ liệu, tạo đối tượng Account
                        taikhoan = new taikhoan(user, name, role);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return taikhoan; // Trả về null nếu sai thông tin, trả về account nếu đúng
    }
}