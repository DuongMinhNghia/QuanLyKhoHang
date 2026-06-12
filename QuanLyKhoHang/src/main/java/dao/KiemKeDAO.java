package dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Date;

public class KiemKeDAO {
    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=QuanLyKhoHang;encrypt=false";
    private static final String DB_USER = "sa"; 
    private static final String DB_PASS = "123"; 

    public String luuPhieuKiemKe(String maKiemKe, Date ngayKiem, String tenDangNhap, 
                                 String[] maHangArr, String[] thucTeArr, String[] chenhLechArr, String[] nguyenNhanArr) {
        Connection conn = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Lưu Phiếu Kiểm Kê
            String sqlPhieu = "INSERT INTO PhieuKiemKeHangHoa (MaKiemKe, NgayKiem, MaNV) "
                            + "VALUES (?, ?, (SELECT MaNV FROM TaiKhoan WHERE TenDangNhap = ?))";
            try (PreparedStatement ps = conn.prepareStatement(sqlPhieu)) {
                ps.setString(1, maKiemKe);
                ps.setDate(2, ngayKiem);
                ps.setString(3, tenDangNhap);
                ps.executeUpdate();
            }

            // 2. Lưu Chi Tiết & 3. Gọi Procedure đồng bộ kho
            String sqlChiTiet = "INSERT INTO ChiTietPhieuKiemKe (MaKiemKe, MaHang, SoLuongThucTe, ChenhLech, NguyenNhan) VALUES (?, ?, ?, ?, ?)";
            String sqlSyncKho = "{CALL SP_XuLyChenhLechKiemKe(?, ?)}";
            
            try (PreparedStatement psChiTiet = conn.prepareStatement(sqlChiTiet);
                 CallableStatement csSync = conn.prepareCall(sqlSyncKho)) {
                
                for (int i = 0; i < maHangArr.length; i++) {
                    // Thêm vào Chi Tiết
                    psChiTiet.setString(1, maKiemKe);
                    psChiTiet.setString(2, maHangArr[i]);
                    psChiTiet.setInt(3, Integer.parseInt(thucTeArr[i]));
                    psChiTiet.setInt(4, Integer.parseInt(chenhLechArr[i]));
                    
                    // Nếu không có chênh lệch, lý do có thể rỗng
                    String lyDo = (nguyenNhanArr[i] == null || nguyenNhanArr[i].isEmpty()) ? "Không chênh lệch" : nguyenNhanArr[i];
                    psChiTiet.setString(5, lyDo);
                    psChiTiet.executeUpdate();
                    
                    // Gọi SP đồng bộ kho (SP này tự động bỏ qua nếu chênh lệch = 0)
                    csSync.setString(1, maKiemKe);
                    csSync.setString(2, maHangArr[i]);
                    csSync.executeUpdate();
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
}