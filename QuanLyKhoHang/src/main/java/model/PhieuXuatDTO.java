package model;
import java.sql.Date;

public class PhieuXuatDTO {
    private String maPhieu;
    private Date ngayLap;
    private String boPhanNhan;
    private String tenHang;
    private int soLuong;
    private double donGia;
    private String maNguoiDuyet;
    private String mucDich; 

    public PhieuXuatDTO() {}

    public PhieuXuatDTO(String maPhieu, Date ngayLap, String boPhanNhan, String tenHang, int soLuong, double donGia, String maNguoiDuyet, String mucDich) {
        this.maPhieu = maPhieu;
        this.ngayLap = ngayLap;
        this.boPhanNhan = boPhanNhan;
        this.tenHang = tenHang;
        this.soLuong = soLuong;
        this.donGia = donGia;
        this.maNguoiDuyet = maNguoiDuyet;
        this.mucDich = mucDich;
    }

    public String getMaPhieu() { return maPhieu; }
    public Date getNgayLap() { return ngayLap; }
    public String getBoPhanNhan() { return boPhanNhan; }
    public String getTenHang() { return tenHang; }
    public int getSoLuong() { return soLuong; }
    public double getDonGia() { return donGia; }
    public String getMaNguoiDuyet() { return maNguoiDuyet; }
    
    public String getMucDich() { return mucDich; }
    public void setMucDich(String mucDich) { this.mucDich = mucDich; }
}