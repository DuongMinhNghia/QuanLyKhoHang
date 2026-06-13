package dao;

import model.HangHoa;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HangHoaDAO {

    // 1. LẤY DANH SÁCH HÀNG HÓA (JOIN ĐỂ LẤY TÊN LOẠI VÀ TÊN VỊ TRÍ)
    public List<HangHoa> getAllHangHoa() {
        List<HangHoa> list = new ArrayList<>();
        String sql = "SELECT h.*, l.TenLoai, v.TenViTri FROM HangHoa h "
                   + "LEFT JOIN LoaiHangHoa l ON h.MaLoai = l.MaLoai "
                   + "LEFT JOIN ViTriKho v ON h.MaViTri = v.MaViTri ORDER BY h.MaHang DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new HangHoa(
                    rs.getString("MaHang"), rs.getString("TenHang"), rs.getString("DVT"),
                    rs.getInt("SoLuongTonKho"), rs.getString("QuyCach"), rs.getInt("HanMucTonToiThieu"),
                    rs.getString("MaLoai"), rs.getString("MaViTri"), rs.getString("TenLoai"), rs.getString("TenViTri")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 2. LẤY DANH SÁCH LOẠI HÀNG HÓA ĐỂ ĐỔ VÀO DROPDOWN
    public Map<String, String> getMapLoaiHang() {
        Map<String, String> map = new HashMap<>();
        String sql = "SELECT MaLoai, TenLoai FROM LoaiHangHoa";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) { map.put(rs.getString("MaLoai"), rs.getString("TenLoai")); }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    // 3. LẤY DANH SÁCH VỊ TRÍ KHO ĐỂ ĐỔ VÀO DROPDOWN
    public Map<String, String> getMapViTriKho() {
        Map<String, String> map = new HashMap<>();
        String sql = "SELECT MaViTri, TenViTri FROM ViTriKho";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) { map.put(rs.getString("MaViTri"), rs.getString("TenViTri")); }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    // 4. KIỂM TRA TRÙNG TÊN SẢN PHẨM
    public boolean kiemTraTrungTen(String tenHang, String maHang_loaiTru) {
        String sql = "SELECT COUNT(*) FROM HangHoa WHERE TenHang = ?";
        if (maHang_loaiTru != null && !maHang_loaiTru.isEmpty()) sql += " AND MaHang != ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tenHang);
            if (maHang_loaiTru != null && !maHang_loaiTru.isEmpty()) ps.setString(2, maHang_loaiTru);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // 5. THÊM MỚI HÀNG HÓA
    public void themHangHoa(HangHoa hh) {
        String sql = "INSERT INTO HangHoa (TenHang, DVT, SoLuongTonKho, QuyCach, HanMucTonToiThieu, MaLoai, MaViTri) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hh.getTenHang());
            ps.setString(2, hh.getDvt());
            ps.setInt(3, hh.getSoLuongTonKho());
            ps.setString(4, hh.getQuyCach());
            ps.setInt(5, hh.getHanMucTonToiThieu());
            ps.setString(6, hh.getMaLoai());
            ps.setString(7, hh.getMaViTri());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 6. SỬA THÔNG TIN HÀNG HÓA
    public void suaHangHoa(HangHoa hh) {
        String sql = "UPDATE HangHoa SET TenHang=?, DVT=?, SoLuongTonKho=?, QuyCach=?, HanMucTonToiThieu=?, MaLoai=?, MaViTri=? WHERE MaHang=?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hh.getTenHang());
            ps.setString(2, hh.getDvt());
            ps.setInt(3, hh.getSoLuongTonKho());
            ps.setString(4, hh.getQuyCach());
            ps.setInt(5, hh.getHanMucTonToiThieu());
            ps.setString(6, hh.getMaLoai());
            ps.setString(7, hh.getMaViTri());
            ps.setString(8, hh.getMaHang());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 7. XÓA HÀNG HÓA
    public String xoaHangHoa(String maHang) {
        String sql = "DELETE FROM HangHoa WHERE MaHang=?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maHang);
            ps.executeUpdate();
            return "SUCCESS";
        } catch (Exception e) { 
            return "LỖI: Không thể xóa mặt hàng này vì đã có lịch sử Nhập/Xuất kho liên quan!";
        }
    }
// ==========================================================================
    // HÀM TÌM KIẾM HÀNG HÓA 
    // ==========================================================================
    public List<HangHoa> searchHangHoa(String tuKhoa) {
        List<HangHoa> list = new ArrayList<>();
        String sql = "SELECT h.*, l.TenLoai, v.TenViTri FROM HangHoa h "
                   + "LEFT JOIN LoaiHangHoa l ON h.MaLoai = l.MaLoai "
                   + "LEFT JOIN ViTriKho v ON h.MaViTri = v.MaViTri "
                   + "WHERE h.TenHang LIKE ? OR h.MaHang LIKE ? "
                   + "ORDER BY h.MaHang DESC";
                   
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + tuKhoa + "%");
            ps.setString(2, "%" + tuKhoa + "%");
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Truyền đủ 10 tham số để khớp với Constructor mới trong HangHoa.java
                    list.add(new HangHoa(
                        rs.getString("MaHang"), 
                        rs.getString("TenHang"), 
                        rs.getString("DVT"),
                        rs.getInt("SoLuongTonKho"), 
                        rs.getString("QuyCach"), 
                        rs.getInt("HanMucTonToiThieu"),
                        rs.getString("MaLoai"), 
                        rs.getString("MaViTri"), 
                        rs.getString("TenLoai"), 
                        rs.getString("TenViTri")
                    ));
                }
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }} 