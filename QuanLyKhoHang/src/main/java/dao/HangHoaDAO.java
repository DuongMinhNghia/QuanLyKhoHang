package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.HangHoa;

public class HangHoaDAO {
    
    // ==============================================================================
    // 1.  Nhận Connection từ bên ngoài truyền vào
    // Dùng cho LapPhieuNhapServlet và LapPhieuXuatServlet để load dữ liệu 
    // ==============================================================================
    public List<HangHoa> getAllHangHoa(Connection conn) {
        List<HangHoa> list = new ArrayList<>();
        String query = "SELECT MaHang, TenHang, MaLoai, SoLuongTonKho, DVT FROM HangHoa";
        
        try (PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new HangHoa(
                    rs.getString("MaHang"), 
                    rs.getString("TenHang"), 
                    rs.getString("MaLoai"), 
                    rs.getInt("SoLuongTonKho"), 
                    rs.getString("DVT")
                ));
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    // ==============================================================================
    // 2Giữ nguyên để các trang cũ (QuanLyHangHoa, KiemKe...) gọi không bị báo lỗi đỏ
    // ==============================================================================
    public List<HangHoa> getAllHangHoa() {
        List<HangHoa> list = new ArrayList<>();
        
        // Mở kết nối thông qua DBConnect, sau đó nhét vào hàm số 1 ở trên
        try (Connection conn = DBConnect.getConnection()) {
            list = getAllHangHoa(conn); 
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    // ==============================================================================
    // 3. HÀM TÌM KIẾM
    // ==============================================================================
    public List<HangHoa> searchHangHoa(String tuKhoa) {
        List<HangHoa> list = new ArrayList<>();
        String query = "SELECT MaHang, TenHang, MaLoai, SoLuongTonKho, DVT " +
                       "FROM HangHoa WHERE TenHang LIKE ? OR MaHang LIKE ?";

        try {
            // Thay thế đoạn bị lỗi bằng DBConnect.getConnection()
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(query)) {

                ps.setString(1, "%" + tuKhoa + "%");
                ps.setString(2, "%" + tuKhoa + "%");

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        HangHoa hh = new HangHoa(
                            rs.getString("MaHang"),
                            rs.getString("TenHang"),
                            rs.getString("MaLoai"),
                            rs.getInt("SoLuongTonKho"),
                            rs.getString("DVT")
                        );
                        list.add(hh);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}