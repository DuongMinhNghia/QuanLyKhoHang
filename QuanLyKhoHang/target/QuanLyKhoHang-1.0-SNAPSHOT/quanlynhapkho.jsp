<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.PhieuNhapDTO" %>
<%@ page import="model.taikhoan" %>
<%
 // 1. KÉO THÔNG TIN TÀI KHOẢN TỪ SESSION 
    taikhoan acc = (taikhoan) session.getAttribute("account");
    if(acc == null) { response.sendRedirect("login.jsp"); return; }
    
 // 2. LOGIC PHÂN QUYỀN
    String role = acc.getVaiTro() != null ? acc.getVaiTro() : "";
  
    boolean showHangHoa      = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc");
    // 1. Chỉ hiện Menu Nhập/Xuất bên trái cho Trưởng kho & Giám đốc
    boolean showMenuNhapXuat = role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc");
    // 2. Cho phép Thủ kho, Trưởng kho, Giám đốc thấy Nút bấm lập phiếu
    boolean showBtnLapPhieu  = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc");
    
    boolean showBaoCao       = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc") || role.equalsIgnoreCase("Admin");
    boolean showLichSu       = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc") || role.equalsIgnoreCase("Admin");
    boolean showTaiKhoan     = role.equalsIgnoreCase("Admin");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Nhập Kho</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f7f6; padding: 20px; }
        .container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h2 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .alert-success { background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-bottom: 20px; font-weight: bold; border: 1px solid #c3e6cb; }
        .toolbar { display: flex; justify-content: space-between; margin-bottom: 20px; }
        .search-box input { padding: 8px; width: 250px; border: 1px solid #ccc; border-radius: 4px; }
        .btn { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; color: white; text-decoration: none; font-weight: bold; }
        .btn-search { background-color: #28a745; }
        .btn-reload { background-color: #17a2b8; margin-left: 5px;}
        .btn-back { background-color: #6c757d; margin-right: 10px;}
        .btn-add { background-color: #ffc107; color: #333; }
        table { width: 100%; border-collapse: collapse; }
        table, th, td { border: 1px solid #dee2e6; }
        th, td { padding: 12px; text-align: center; }
        th { background-color: #f8f9fa; }
        .badge-pending { background-color: #ffeeba; color: #856404; padding: 5px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-approved { background-color: #d4edda; color: #155724; padding: 5px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
    </style>
</head>
<body>
<!-- ================= SIDEBAR ================= -->
       <div class="sidebar">
        <div class="sidebar-logo">📦 Minh Phát</div>
        <div class="menu-title">MENU CHÍNH</div>
        
        <a href="home.jsp" class="menu-item">Dashboard</a>
        
       <% if(showMenuNhapXuat) { %>
            <a href="QuanLyDanhSachNhapServlet" class="menu-item">Quản lý Nhập kho</a>
            <a href="QuanLyDanhSachXuatServlet" class="menu-item">Quản lý Xuất kho</a>
             <a href="#" class="menu-item">Nhà cung cấp</a>
        <% } %>

        <% if(showHangHoa) { %>
            <a href="LoadDanhSachKhoServlet" class="menu-item ">Quản lý hàng hóa</a>
            <a href="KiemKeServlet" class="menu-item">Kiểm kê</a>
        <% } %>
        
        <% if(showBaoCao) { %>
            <a href="BaoCaoServlet" class="menu-item">Báo cáo</a>
        <% } %>
        
        <% if(showLichSu) { %>
            <a href="LichSuServlet" class="menu-item">Lịch sử tồn kho</a>
        <% } %>

        <% if(showTaiKhoan) { %>
            <a href="#" class="menu-item">Quản lý tài khoản</a>
        <% } %>
    </div>
<div class="container">
    <h2>Danh Sách Phiếu Nhập Kho</h2>
    
    <% if("success".equals(request.getParameter("msg"))) { %>
        <div class="alert-success">
            ✅ Lập phiếu nhập kho thành công! Đang chờ Trưởng kho duyệt để chốt tồn kho.
        </div>
    <% } %>

    <div class="toolbar">
        <form action="LoadDanhSachPhieuNhapServlet" method="GET" class="search-box">
            <input type="text" name="tuKhoa" placeholder="Tìm theo tên SP hoặc mã phiếu...">
            <button type="submit" class="btn btn-search">Tìm kiếm</button>
            <a href="LoadDanhSachPhieuNhapServlet"><button type="button" class="btn btn-reload">🔄 Tải lại</button></a>
        </form>

        <div>
            <a href="home.jsp"><button type="button" class="btn btn-back">⬅ Quay lại Trang Chủ</button></a>
            <a href="LapPhieuNhapServlet"><button type="button" class="btn btn-add">+ Lập Phiếu Nhập Mới</button></a>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>Mã Phiếu</th>
                <th>Ngày Lập</th>
                <th>Nhà Cung Cấp</th>
                <th>Sản Phẩm Nhập</th>
                <th>Số Lượng</th>
                <th>Đơn Giá</th>
                <th>Trạng Thái</th>
            </tr>
        </thead>
        <tbody>
            <% 
                List<PhieuNhapDTO> list = (List<PhieuNhapDTO>) request.getAttribute("danhSachPN");
                if(list != null && !list.isEmpty()) {
                    for(PhieuNhapDTO pn : list) {
            %>
            <tr>
                <td><strong><%= pn.getMaPhieu() %></strong></td>
                <td><%= pn.getNgayLap() %></td>
                <td style="text-align: left; font-weight: bold;"><%= pn.getTenNCC() %></td>
                <td style="text-align: left;"><%= pn.getTenHang() %></td>
                <td><%= pn.getSoLuong() %></td>
                <td>
                    <% java.text.DecimalFormat df = new java.text.DecimalFormat("#,### VNĐ"); %>
                    <%= df.format(pn.getDonGia()) %>
                </td>
                <td>
                    <% if(pn.getMaNguoiDuyet() == null) { %>
                        <span class="badge-pending">⏳ Chờ duyệt</span>
                    <% } else { %>
                        <span class="badge-approved">✅ Đã duyệt</span>
                    <% } %>
                </td>
            </tr>
            <% 
                    }
                } else {
            %>
            <tr>
                <td colspan="7" style="color: #666; font-style: italic;">Chưa có phiếu nhập nào hoặc không tìm thấy kết quả.</td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

</body>
</html>