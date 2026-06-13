<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.taikhoan" %>
<%@ page import="model.HangHoa" %>
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
    <title>Kiểm Kê Hàng Hóa - WMS</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { display: flex; background-color: #f5f6f8; height: 100vh; overflow: hidden; }
        .sidebar { width: 250px; background-color: #ffffff; border-right: 1px solid #e0e0e0; padding: 20px 0; }
        .sidebar-logo { font-size: 20px; font-weight: bold; color: #333; padding: 0 20px 20px; border-bottom: 1px solid #eee; margin-bottom: 10px; }
        .menu-title { font-size: 12px; color: #888; font-weight: bold; padding: 10px 20px; text-transform: uppercase; }
        .menu-item { padding: 12px 20px; color: #555; text-decoration: none; display: block; font-weight: 500; }
        .menu-item:hover { background-color: #f0f4ff; color: #0056b3; }
        .menu-item.active { background-color: #e6efff; color: #0056b3; border-right: 3px solid #0056b3; }
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .topbar { height: 60px; background-color: #ffffff; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; }
        .topbar .title { font-size: 18px; font-weight: bold; color: #333; }
        .topbar .user-info { font-size: 14px; color: #555; }
        .badge-role { background-color: #ffe4e4; color: #d93025; padding: 3px 8px; border-radius: 12px; font-size: 12px; font-weight: bold; margin-left: 10px; }
        .content-body { padding: 30px; }
        .card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 25px; margin-bottom: 20px; }
        .card-header { font-size: 18px; font-weight: bold; color: #333; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee; }
        .form-row { display: flex; gap: 20px; margin-bottom: 15px; }
        .form-group { flex: 1; display: flex; flex-direction: column; }
        .form-group label { font-size: 13px; color: #666; margin-bottom: 5px; font-weight: bold; }
        .form-control { padding: 10px; border: 1px solid #ccc; border-radius: 5px; font-size: 14px; outline: none; transition: border-color 0.3s; }
        .form-control:focus { border-color: #0056b3; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background-color: #f8f9fa; color: #555; font-size: 13px; text-transform: uppercase; }
        td { font-size: 14px; color: #333; }
        .btn { padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; font-size: 14px; transition: 0.2s; text-decoration: none; display: inline-block; text-align: center;}
        .btn-primary { background-color: #00b894; color: white; } 
        .btn-primary:hover { background-color: #00a383; }
        .btn-secondary { background-color: #f1f3f4; color: #333; border: 1px solid #ccc;}
        .btn-secondary:hover { background-color: #e2e6ea; }
        .btn-danger { background-color: #ff7675; color: white; padding: 6px 12px; font-size: 12px;}
        .action-footer { display: flex; justify-content: flex-end; gap: 15px; margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee;}
    </style>
</head>
<body>

   <!-- ================= SIDEBAR================= -->
    <!-- ================= SIDEBAR ================= -->
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
            <a href="LoadDanhSachKhoServlet" class="menu-item ">Quản lý hàng hóa</a>
            <a href="KiemKeServlet" class="menu-item active">Kiểm kê</a>
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
                <%= acc.getHoTen() != null ? acc.getHoTen() : acc.getTenDangNhap() %> 
                <span class="badge-role"><%= acc.getVaiTro() %></span>
                <a href="LogoutServlet" style="margin-left: 15px; color: #d93025; text-decoration: none;">[➜ Logout]</a>
            </div>
        </div>

        <div class="content-body">
            
            <% if(request.getAttribute("thongBaoLoi") != null) { %>
                <div style="background-color: #ffcccc; color: #cc0000; padding: 15px; border-radius: 5px; margin-bottom: 20px; font-weight: bold;">
                    ⚠️ LỖI: <%= request.getAttribute("thongBaoLoi") %>
                </div>
            <% } %>

            <form action="LuuKiemKeServlet" method="POST" id="formKiemKe">
                
                <div class="card">
                    <div class="card-header">Tạo Phiếu Kiểm Kê Mới</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Mã Phiếu Kiểm Kê (Tạo tự động)</label>
                            <input type="text" name="maKiemKe" class="form-control" 
                                   value="<%= request.getAttribute("maKiemKeAuto") != null ? request.getAttribute("maKiemKeAuto") : "" %>" 
                                   readonly style="background-color: #e9ecef; font-weight: bold; color: #0056b3;">
                        </div>
                        <div class="form-group">
                            <label>Ngày Kiểm Kê</label>
                            <input type="date" name="ngayKiem" class="form-control" id="todayDate" readonly style="background-color: #e9ecef; font-weight: bold; pointer-events: none;">
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">Đối Chiếu Hàng Hóa Thực Tế Tại Kho</div>
                    
                    <div class="form-row" style="background-color: #fff3cd; padding: 15px; border-radius: 5px;">
                        <div class="form-group" style="flex: 2;">
                            <label>Chọn Mặt Hàng Cần Kiểm Kê</label>
                            <% String maHHDuocChon = request.getParameter("maHH"); %>
                            <select id="maHangTam" class="form-control" onchange="hienThiTonKho()">
                                <option value="" data-tonkho="0">-- Chọn hàng hóa --</option>
                                <%
                                    List<HangHoa> listHH = (List<HangHoa>) request.getAttribute("danhSachHH");
                                    if(listHH != null) {
                                        for(HangHoa hh : listHH) {
                                            String isSelected = (maHHDuocChon != null && maHHDuocChon.equals(hh.getMaHH())) ? "selected" : "";
                                %>
                                <option value="<%= hh.getMaHH() %>" data-name="<%= hh.getTenHH() %>" data-tonkho="<%= hh.getSoLuongTon() %>" <%= isSelected %>>
                                    <%= hh.getMaHH() %> - <%= hh.getTenHH() %>
                                </option>
                                <%      }
                                    } 
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Tồn Kho (Lý thuyết)</label>
                            <input type="text" id="tonKhoTam" class="form-control" readonly style="background-color: #e9ecef;">
                        </div>
                        <div class="form-group">
                            <label>Đếm Thực Tế Tại Kệ</label>
                            <input type="number" id="thucTeTam" class="form-control" oninput="tinhChenhLech()">
                        </div>
                        <div class="form-group">
                            <label>Độ Lệch</label>
                            <input type="text" id="chenhLechTam" class="form-control" readonly style="font-weight:bold; color:red;">
                        </div>
                    </div>
                    
                    <div class="form-row" style="margin-top: 10px;">
                        <div class="form-group" style="flex: 3;">
                            <label>Nguyên Nhân (BẮT BUỘC nếu Độ lệch khác 0)</label>
                            <input type="text" id="nguyenNhanTam" class="form-control" placeholder="Ghi chú nguyên nhân lệch kho (hư hỏng, mất mát, đếm sai lần trước...)">
                        </div>
                        <div class="form-group" style="justify-content: flex-end;">
                            <button type="button" class="btn btn-secondary" onclick="themDong()" style="height: 40px; background-color: #ffc107; border:none; color: #333;">➕ Ghi Nhận Xuống Bảng</button>
                        </div>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th>Mã Hàng</th>
                                <th>Tên Mặt Hàng</th>
                                <th>Lý Thuyết</th>
                                <th>Thực Tế</th>
                                <th>Chênh Lệch</th>
                                <th>Nguyên Nhân</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="bangChiTiet"></tbody>
                    </table>
                </div>

                <div class="action-footer">
                    <a href="LoadDanhSachKhoServlet" class="btn btn-secondary">Hủy Bỏ</a>
                    <button type="button" onclick="kiemTraVaSubmit()" class="btn btn-primary">💾 Hoàn Tất & Cập Nhật Số Dư Kho</button>
                </div>

            </form>
        </div>
    </div>

    <script>
        window.onload = function() {
            var today = new Date();
            var todayStr = today.toISOString().split('T')[0];
            var dateInput = document.getElementById('todayDate');
            
            dateInput.value = todayStr;
            dateInput.min = todayStr; // Khóa ngày quá khứ
            
            var dropdown = document.getElementById('maHangTam');
            if (dropdown.value !== "") {
                hienThiTonKho();
            }
        };

        function hienThiTonKho() {
            var selectBox = document.getElementById('maHangTam');
            if (selectBox.value === "") {
                document.getElementById('tonKhoTam').value = "";
                document.getElementById('thucTeTam').value = "";
                document.getElementById('chenhLechTam').value = "";
                return;
            }
            var tonKho = selectBox.options[selectBox.selectedIndex].getAttribute('data-tonkho');
            document.getElementById('tonKhoTam').value = tonKho;
            document.getElementById('thucTeTam').value = tonKho; 
            tinhChenhLech(); 
        }

        function tinhChenhLech() {
            var lyThuyet = document.getElementById('tonKhoTam').value || 0;
            var thucTe = document.getElementById('thucTeTam').value || 0;
            var chenhLech = parseInt(thucTe) - parseInt(lyThuyet);
            
            var oChenhLech = document.getElementById('chenhLechTam');
            oChenhLech.value = chenhLech;
            
            if (chenhLech < 0) oChenhLech.style.color = 'red';
            else if (chenhLech > 0) oChenhLech.style.color = 'blue';
            else oChenhLech.style.color = 'black';
        }

        function themDong() {
            var selectBox = document.getElementById('maHangTam');
            var maHang = selectBox.value;
            if(!maHang) { 
                alert("Vui lòng chọn một mặt hàng để kiểm kê!"); 
                return; 
            }

            var tenHang = selectBox.options[selectBox.selectedIndex].getAttribute('data-name');
            var lyThuyet = document.getElementById('tonKhoTam').value;
            var thucTe = document.getElementById('thucTeTam').value;
            var chenhLech = document.getElementById('chenhLechTam').value;
            var nguyenNhan = document.getElementById('nguyenNhanTam').value;

            if (parseInt(chenhLech) !== 0 && nguyenNhan.trim() === "") {
                alert("⚠️ HỆ THỐNG PHÁT HIỆN CHÊNH LỆCH KHO (" + chenhLech + " sản phẩm)!\n\nBạn BẮT BUỘC phải điền lý do vào ô Nguyên Nhân để hệ thống ghi log lưu vết!");
                document.getElementById('nguyenNhanTam').focus();
                return;
            }

            if(nguyenNhan.trim() === "") {
                nguyenNhan = "Khớp số lượng";
            }

            var tr = document.createElement('tr');
            tr.innerHTML = `
                <td><input type="hidden" name="maHang[]" value="`+maHang+`">`+maHang+`</td>
                <td>`+tenHang+`</td>
                <td>`+lyThuyet+`</td>
                <td><input type="hidden" name="thucTe[]" value="`+thucTe+`"><b style="color:#0056b3; font-size:16px;">`+thucTe+`</b></td>
                <td><input type="hidden" name="chenhLech[]" value="`+chenhLech+`"><span style="color:`+(chenhLech!=0?'red':'black')+`; font-weight:bold;">`+chenhLech+`</span></td>
                <td><input type="hidden" name="nguyenNhan[]" value="`+nguyenNhan+`"><i>`+nguyenNhan+`</i></td>
                <td><button type="button" class="btn btn-danger" onclick="this.parentNode.parentNode.remove()">Xóa</button></td>
            `;
            
            document.getElementById('bangChiTiet').appendChild(tr);

            selectBox.value = "";
            document.getElementById('tonKhoTam').value = "";
            document.getElementById('thucTeTam').value = "";
            document.getElementById('chenhLechTam').value = "";
            document.getElementById('nguyenNhanTam').value = "";
        }

        function kiemTraVaSubmit() {
            var dateInput = document.getElementById('todayDate').value;
            var todayStr = new Date().toISOString().split('T')[0];
            if (dateInput < todayStr) {
                alert("❌ Lỗi: Bạn không thể lưu phiếu kiểm kê với ngày trong quá khứ!");
                return;
            }

            var soLuongKiemKe = document.getElementById('bangChiTiet').children.length;
            if(soLuongKiemKe === 0) {
                alert("❌ Bạn chưa ghi nhận mặt hàng nào vào danh sách kiểm kê!");
            } else {
                if(confirm("⚠️ LƯU Ý QUAN TRỌNG:\n\nHành động này sẽ CHỐT và GHI ĐÈ số dư Tồn Kho hiện tại bằng đúng số lượng Thực Tế.\n\nBạn có chắc chắn muốn lưu phiếu Kiểm kê này không?")) {
                    document.getElementById('formKiemKe').submit();
                }
            }
        }
    </script>
</body>
</html>