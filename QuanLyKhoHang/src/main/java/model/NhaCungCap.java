package model;

public class NhaCungCap {
    private String maNCC;
    private String tenNCC;

    public NhaCungCap() {}
    public NhaCungCap(String maNCC, String tenNCC) {
        this.maNCC = maNCC;
        this.tenNCC = tenNCC;
    }
    public String getMaNCC() { return maNCC; }
    public void setMaNCC(String maNCC) { this.maNCC = maNCC; }
    public String getTenNCC() { return tenNCC; }
    public void setTenNCC(String tenNCC) { this.tenNCC = tenNCC; }
}