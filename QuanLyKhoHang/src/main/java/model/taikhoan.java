package model;

public class taikhoan {
    private String tenDangNhap;
    private String hoTen;
    private String vaiTro;

    // Constructor
    public taikhoan(String tenDangNhap, String hoTen, String vaiTro) {
        this.tenDangNhap = tenDangNhap;
        this.hoTen = hoTen;
        this.vaiTro = vaiTro;
    }

    // Getters
    public String getTenDangNhap() {
        return tenDangNhap;
    }

    public String getHoTen() {
        return hoTen;
    }

    public String getVaiTro() {
        return vaiTro;
    }
}