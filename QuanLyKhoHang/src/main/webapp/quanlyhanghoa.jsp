<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.HangHoa" %>
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
    <title>Quản Lý Hàng Hóa - WMS Admin</title>
    <style>
        /* CSS RESET & FLEXBOX (Thứ giúp Sidebar nằm đúng bên trái) */
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { display: flex; background-color: #f5f6f8; height: 100vh; overflow: hidden; }
        
        /* SIDEBAR CHUẨN ĐỒNG BỘ */
        .sidebar { width: 250px; background-color: #ffffff; border-right: 1px solid #e0e0e0; padding: 20px 0; overflow-y: auto; }
        .sidebar-logo { font-size: 20px; font-weight: bold; color: #2c3e50; padding: 0 20px 20px; border-bottom: 1px solid #eee; margin-bottom: 10px; display: flex; align-items: center; gap: 10px;}
        .menu-title { font-size: 11px; color: #888; font-weight: bold; padding: 10px 20px; text-transform: uppercase; }
        .menu-item { padding: 12px 20px; color: #555; text-decoration: none; display: flex; align-items: center; font-weight: 500; font-size: 14px; transition: 0.2s;}
        .menu-item:hover { background-color: #f0f4ff; color: #4b49ac; }
        .menu-item.active { background-color: #e6efff; color: #4b49ac; border-right: 3px solid #4b49ac; font-weight: bold;}

        /* MAIN CONTENT */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .topbar { height: 60px; background-color: #ffffff; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; }
        .topbar .title { font-size: 18px; font-weight: bold; color: #333; }
        .user-info { display: flex; align-items: center; gap: 10px; font-size: 13px; }
        .badge-role { background-color: #eaf4fc; color: #3498db; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; margin-left: 5px; }

        .content-body { padding: 30px; }
        .card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.02); padding: 25px; margin-bottom: 20px; border: 1px solid #eee; }
        
        .page-title { font-size: 22px; font-weight: bold; color: #2c3e50; margin-bottom: 20px; border-bottom: 2px solid #f1f2f6; padding-bottom: 10px;}
        
        /* TOOLBAR TÌM KIẾM */
        .toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .search-box { display: flex; gap: 10px; }
        .search-box input[type="text"] { padding: 10px; width: 300px; border: 1px solid #dcdde1; border-radius: 5px; font-size: 14px; outline: none; transition: 0.3s; }
        .search-box input[type="text"]:focus { border-color: #4b49ac; }
        
        /* BUTTONS */
        .btn { padding: 10px 15px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; font-size: 14px; text-decoration: none; display: inline-block; transition: 0.2s;}
        .btn-search { background-color: #3498db; color: white; }
        .btn-search:hover { background-color: #2980b9; }
        .btn-reload { background-color: #f8f9fa; color: #333; border: 1px solid #dcdde1; }
        .btn-reload:hover { background-color: #e9ecef; }
        .btn-import { background-color: #2ecc71; color: white; }
        .btn-import:hover { background-color: #27ae60; }
        .btn-export { background-color: #f39c12; color: white; }
        .btn-export:hover { background-color: #d68910; }
        .btn-action { background-color: #eaf4fc; color: #3498db; padding: 6px 12px; font-size: 12px; border-radius: 4px; border: 1px solid #3498db;}
        .btn-action:hover { background-color: #3498db; color: white; }

        /* TABLE */
        .table-wrapper { overflow-x: auto; border: 1px solid #eee; border-radius: 5px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 15px; text-align: center; border-bottom: 1px solid #f1f2f6; font-size: 14px; }
        th { background-color: #fcfcfd; color: #333; font-weight: bold; position: sticky; top: 0; z-index: 1;}
        tr:hover { background-color: #fcfcfd; }
        td.text-left { text-align: left; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-logo">📦 Minh Phát</div>
        <div class="menu-title">MENU CHÍNH</div>
        
        <a href="home.jsp" class="menu-item">Dashboard</a>
        
         <% if(showMenuNhapXuat) { %>
            <a href="QuanLyDanhSachNhapServlet" class="menu-item">Quản lý Nhập kho</a>
            <a href="QuanLyDanhSachXuatServlet" class="menu-item">Quản lý Xuất kho</a>
             <a href="QuanLyNhaCungCapServlet" class="menu-item">Nhà cung cấp</a>
        <% } %>

        <% if(showHangHoa) { %>
            <a href="LoadDanhSachKhoServlet" class="menu-item active">Quản lý hàng hóa</a>
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

    <div class="main-content">
        
        <div class="topbar">
            <div class="title">Hệ thống Quản lý Kho</div>
            <div class="user-info">
                <div style="text-align: right;">
                    <b><%= acc.getHoTen() != null ? acc.getHoTen() : acc.getTenDangNhap() %></b>
                    <span class="badge-role"><%= acc.getVaiTro() %></span>
                </div>
                <a href="LogoutServlet" style="color: #e74c3c; text-decoration: none; font-size: 18px; margin-left: 10px;" title="Đăng xuất">🚪</a>
            </div>
        </div>

        <div class="content-body">
            <div class="card">
                <div class="page-title">Danh Sách Hàng Hóa Trong Kho</div>
                
                <div class="toolbar">
                    <form action="TimKiemHangHoaServlet" method="GET" class="search-box">
                        <input type="text" name="tuKhoa" placeholder="Nhập tên hoặc mã hàng hóa..." required>
                        <button type="submit" class="btn btn-search">🔍 Tìm kiếm</button>
                        <a href="LoadDanhSachKhoServlet" class="btn btn-reload" style="text-decoration:none;">🔄 Tải lại</a>
                    </form>

                   <div class="action-buttons">
                        <% if(showBtnLapPhieu) { %>
                            <a href="LapPhieuNhapServlet" class="btn btn-import">+ Lập Phiếu Nhập</a>
                            <a href="LapPhieuXuatServlet" class="btn btn-export">- Lập Phiếu Xuất</a>
                        <% } %>
                    </div>
                </div>

                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Mã Hàng Hóa</th>
                                <th>Tên Hàng Hóa</th>
                                <th>Danh Mục</th>
                                <th>Số Lượng Tồn</th>
                                <th>Đơn Vị Tính</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                List<HangHoa> list = (List<HangHoa>) request.getAttribute("danhSachHH");
                                if(list != null && !list.isEmpty()) {
                                    for(HangHoa hh : list) {
                            %>
                            <tr>
                                <td><strong><%= hh.getMaHH() %></strong></td>
                                <td class="text-left"><%= hh.getTenHH() %></td>
                                <td><%= hh.getDanhMuc() %></td>
                                
                                <% if(hh.getSoLuongTon() == 0) { %>
                                    <td style="color: #e74c3c; font-weight: bold;">Hết hàng (0)</td>
                                <% } else { %>
                                    <td style="font-weight: bold; color: #2c3e50;"><%= hh.getSoLuongTon() %></td>
                                <% } %>
                                
                                <td><%= hh.getDonViTinh() %></td>
                                <td>
                                    <a href="KiemKeServlet?maHH=<%= hh.getMaHH() %>">
                                        <button type="button" class="btn btn-action">Kiểm Kê</button>
                                    </a>
                                </td>
                            </tr>
                            <% 
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="6" style="color: #666; font-style: italic; padding: 30px;">
                                    Không có dữ liệu hàng hóa nào trong kho.
                                </td>
                            </tr>
                            <%  } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>