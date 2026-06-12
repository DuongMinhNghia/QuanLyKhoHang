package model;

public class HangHoa {
    private String maHH;
    private String tenHH;
    private String danhMuc;
    private int soLuongTon;
    private String donViTinh;

    // Constructor rỗng
    public HangHoa() {
    }

    // Constructor đầy đủ
    public HangHoa(String maHH, String tenHH, String danhMuc, int soLuongTon, String donViTinh) {
        this.maHH = maHH;
        this.tenHH = tenHH;
        this.danhMuc = danhMuc;
        this.soLuongTon = soLuongTon;
        this.donViTinh = donViTinh;
    }

    // Các hàm Getter và Setter
    public String getMaHH() { return maHH; }
    public void setMaHH(String maHH) { this.maHH = maHH; }

    public String getTenHH() { return tenHH; }
    public void setTenHH(String tenHH) { this.tenHH = tenHH; }

    public String getDanhMuc() { return danhMuc; }
    public void setDanhMuc(String danhMuc) { this.danhMuc = danhMuc; }

    public int getSoLuongTon() { return soLuongTon; }
    public void setSoLuongTon(int soLuongTon) { this.soLuongTon = soLuongTon; }

    public String getDonViTinh() { return donViTinh; }
    public void setDonViTinh(String donViTinh) { this.donViTinh = donViTinh; }
}