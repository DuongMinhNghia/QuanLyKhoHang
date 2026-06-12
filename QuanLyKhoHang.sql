CREATE DATABASE QuanLyKhoHang
GO
use QuanLyKhoHang
go
CREATE FUNCTION dbo.fn_AutoMaHang()
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @NextID VARCHAR(20);
    DECLARE @MaxID VARCHAR(20);
    
    SELECT @MaxID = MAX(MaHang) FROM HangHoa;
    
    IF @MaxID IS NULL
        SET @NextID = 'SP001';
    ELSE
    BEGIN
        -- Bỏ 2 ký tự đầu ('SP'), lấy phần số cộng thêm 1
        DECLARE @Num INT = CAST(SUBSTRING(@MaxID, 3, LEN(@MaxID)) AS INT) + 1;
        -- Ghép lại chữ 'SP' và định dạng số có 3 chữ số (001, 002)
        SET @NextID = 'SP' + RIGHT('000' + CAST(@Num AS VARCHAR(10)), 3);
    END
    RETURN @NextID;
END;
GO

-- 2. Hàm sinh mã Nhà Cung Cấp (VD: NCC001, NCC002...)
CREATE FUNCTION dbo.fn_AutoMaNCC()
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @NextID VARCHAR(20);
    DECLARE @MaxID VARCHAR(20);
    SELECT @MaxID = MAX(MaNCC) FROM NhaCungCap;
    
    IF @MaxID IS NULL SET @NextID = 'NCC001';
    ELSE
    BEGIN
        DECLARE @Num INT = CAST(SUBSTRING(@MaxID, 4, LEN(@MaxID)) AS INT) + 1;
        SET @NextID = 'NCC' + RIGHT('000' + CAST(@Num AS VARCHAR(10)), 3);
    END
    RETURN @NextID;
END;
GO

-- 3. Hàm sinh mã Nhân Viên (VD: NV001, NV002...)
CREATE FUNCTION dbo.fn_AutoMaNV()
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @NextID VARCHAR(20);
    DECLARE @MaxID VARCHAR(20);
    SELECT @MaxID = MAX(MaNV) FROM NhanVien;
    
    IF @MaxID IS NULL SET @NextID = 'NV001';
    ELSE
    BEGIN
        DECLARE @Num INT = CAST(SUBSTRING(@MaxID, 3, LEN(@MaxID)) AS INT) + 1;
        SET @NextID = 'NV' + RIGHT('000' + CAST(@Num AS VARCHAR(10)), 3);
    END
    RETURN @NextID;
END;
GO
CREATE TABLE BoPhan (
    MaBoPhan VARCHAR(20) PRIMARY KEY,
    TenBoPhan NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(255)
);

-- Bảng Loại Hàng Hóa 
CREATE TABLE LoaiHangHoa (
    MaLoai VARCHAR(20) PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL
);

-- Bảng Vị Trí Kho 
CREATE TABLE ViTriKho (
    MaViTri VARCHAR(20) PRIMARY KEY,
    TenViTri NVARCHAR(100) NOT NULL,
    TrangThai NVARCHAR(50)
);

-- ====================================================================
-- PHẦN 2: CÁC BẢNG QUẢN LÝ HỆ THỐNG & DANH MỤC
-- ====================================================================
-- Bảng nhà cung cấp
CREATE TABLE NhaCungCap (
    MaNCC VARCHAR(20) PRIMARY KEY DEFAULT dbo.fn_AutoMaNCC(),
    TenNCC NVARCHAR(150) NOT NULL,
    DiaChi NVARCHAR(255),
    SDT VARCHAR(15),      
    Email VARCHAR(100)    
);

-- Bảng Nhân Viên 
CREATE TABLE NhanVien (
    MaNV VARCHAR(20) PRIMARY KEY DEFAULT dbo.fn_AutoMaNV(),
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15),
    DiaChi NVARCHAR(255),
    NgaySinh DATE,
    MaBoPhan VARCHAR(20), 
    FOREIGN KEY (MaBoPhan) REFERENCES BoPhan(MaBoPhan)
);
-- Bảng tài khoản
CREATE TABLE TaiKhoan (
    TenDangNhap VARCHAR(50) PRIMARY KEY,
    MatKhau VARCHAR(255) NOT NULL,
    VaiTro NVARCHAR(50),
    TrangThai NVARCHAR(50),
    MaNV VARCHAR(20) UNIQUE,
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

-- Bảng Hàng Hóa 
CREATE TABLE HangHoa (
    MaHang VARCHAR(20) PRIMARY KEY DEFAULT dbo.fn_AutoMaHang(),
    TenHang NVARCHAR(150) NOT NULL,
    DVT NVARCHAR(50),
    SoLuongTonKho INT DEFAULT 0,
    QuyCach NVARCHAR(100),       
    HanMucTonToiThieu INT,   
    MaLoai VARCHAR(20),
    MaViTri VARCHAR(20),
    FOREIGN KEY (MaLoai) REFERENCES LoaiHangHoa(MaLoai),
    FOREIGN KEY (MaViTri) REFERENCES ViTriKho(MaViTri)
);

-- ====================================================================
-- PHẦN 3: CÁC BẢNG NGHIỆP VỤ XUẤT / NHẬP / KIỂM KÊ / DỰ BÁO
-- ====================================================================

-- 5. Bảng Phiếu Đề Nghị Xuất
CREATE TABLE PhieuDeNghiXuat (
    MaDeNghi VARCHAR(20) PRIMARY KEY,
    NgayDeNghi DATE,
    LyDo NVARCHAR(255),
    TrangThai NVARCHAR(50)
);

-- 6. Bảng Chi Tiết Phiếu Đề Nghị Xuất (Đề xuất thêm để lưu mặt hàng xin xuất)
CREATE TABLE ChiTietPhieuDeNghiXuat (
    MaDeNghi VARCHAR(20),
    MaHang VARCHAR(20),
    SoLuongYeuCau INT,
    PRIMARY KEY (MaDeNghi, MaHang),
    FOREIGN KEY (MaDeNghi) REFERENCES PhieuDeNghiXuat(MaDeNghi),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang)
);

-- 7. Bảng Phiếu Nhập Kho
CREATE TABLE PhieuNhapKho (
    MaPhieu VARCHAR(20) PRIMARY KEY,
    NgayLap DATE,
    MaNV VARCHAR(20),
    MaNCC VARCHAR(20),
    SoHoaDon VARCHAR(50),       
    GhiChu NVARCHAR(255),       
    MaNguoiDuyet VARCHAR(20),   
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC),
    FOREIGN KEY (MaNguoiDuyet) REFERENCES NhanVien(MaNV)
);

-- 8. Bảng Chi Tiết Phiếu Nhập Kho
CREATE TABLE ChiTietPhieuNhapKho (
    MaPhieu VARCHAR(20),
    MaHang VARCHAR(20),
    SoLuong INT,
    DonGia DECIMAL(18,2),
    PRIMARY KEY (MaPhieu, MaHang),
    FOREIGN KEY (MaPhieu) REFERENCES PhieuNhapKho(MaPhieu),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang)
);

-- 9. Bảng Phiếu Xuất Kho
CREATE TABLE PhieuXuatKho (
    MaPhieu VARCHAR(20) PRIMARY KEY,
    NgayLap DATE,
    MaNV VARCHAR(20),
    MaDeNghi VARCHAR(20),       
    BoPhanNhan NVARCHAR(100),   
    MucDich NVARCHAR(255),     
    MaNguoiDuyet VARCHAR(20),   
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    FOREIGN KEY (MaDeNghi) REFERENCES PhieuDeNghiXuat(MaDeNghi),
    FOREIGN KEY (MaNguoiDuyet) REFERENCES NhanVien(MaNV)
);

-- 10. Bảng Chi Tiết Phiếu Xuất Kho
CREATE TABLE ChiTietPhieuXuatKho (
    MaPhieu VARCHAR(20),
    MaHang VARCHAR(20),
    SoLuong INT,
    DonGia DECIMAL(18,2),
    PRIMARY KEY (MaPhieu, MaHang),
    FOREIGN KEY (MaPhieu) REFERENCES PhieuXuatKho(MaPhieu),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang)
);

-- 11. Bảng Phiếu Kiểm Kê Hàng Hóa
CREATE TABLE PhieuKiemKeHangHoa (
    MaKiemKe VARCHAR(20) PRIMARY KEY,
    NgayKiem DATE,
    MaNV VARCHAR(20),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

-- 12. Bảng Chi Tiết Phiếu Kiểm Kê
CREATE TABLE ChiTietPhieuKiemKe (
    MaKiemKe VARCHAR(20),
    MaHang VARCHAR(20),
    SoLuongThucTe INT,
    ChenhLech INT,
    NguyenNhan NVARCHAR(255),  
    PRIMARY KEY (MaKiemKe, MaHang),
    FOREIGN KEY (MaKiemKe) REFERENCES PhieuKiemKeHangHoa(MaKiemKe),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang)
);

-- 13. Bảng Lịch Sử Tồn Kho
CREATE TABLE LichSuTonKho (
    MaHang VARCHAR(20),
    NgayGhiNhan DATETIME,
    LoaiBienDong NVARCHAR(50), 
    SoLuongThayDoi INT,
    MaChungTu VARCHAR(20),      
    GhiChu NVARCHAR(255),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang)
);

-- 14. Bảng Kết Quả Dự Báo
CREATE TABLE KetQuaDuBao (
    MaDuBao VARCHAR(20) PRIMARY KEY,
    DoChinhXac DECIMAL(5,2),
    NgayDuBao DATE,
    SoLuongDuBao INT,
    MaHang VARCHAR(20),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang)
);


-- Index hỗ trợ tìm kiếm nhanh phiếu nhập/xuất theo khoảng thời gian (phục vụ lập báo cáo định kỳ)
CREATE NONCLUSTERED INDEX IDX_PhieuNhapKho_NgayLap ON PhieuNhapKho(NgayLap);
CREATE NONCLUSTERED INDEX IDX_PhieuXuatKho_NgayLap ON PhieuXuatKho(NgayLap);

-- Index hỗ trợ tìm kiếm và tính toán tổng số lượng theo từng mặt hàng
CREATE NONCLUSTERED INDEX IDX_CTNhap_MaHang ON ChiTietPhieuNhapKho(MaHang);
CREATE NONCLUSTERED INDEX IDX_CTXuat_MaHang ON ChiTietPhieuXuatKho(MaHang);

-- Index trên bảng Lịch Sử Tồn Kho để truy xuất đối chiếu dữ liệu nhanh chóng
CREATE NONCLUSTERED INDEX IDX_LichSuTonKho_MaHang_Ngay ON LichSuTonKho(MaHang, NgayGhiNhan);


go
-- Trigger 1: Tự động cộng tồn kho và ghi lịch sử khi NHẬP KHO
CREATE TRIGGER TRG_TuDongNhapKho
ON ChiTietPhieuNhapKho
AFTER INSERT
AS
BEGIN
    -- 1. Cập nhật cộng thêm số lượng tồn kho
    UPDATE h
    SET h.SoLuongTonKho = h.SoLuongTonKho + i.SoLuong
    FROM HangHoa h
    JOIN inserted i ON h.MaHang = i.MaHang;

    -- 2. Ghi  vào Lịch Sử Tồn Kho
    INSERT INTO LichSuTonKho (MaHang, NgayGhiNhan, LoaiBienDong, SoLuongThayDoi, MaChungTu, GhiChu)
    SELECT 
        i.MaHang, 
        GETDATE(), 
        N'Nhập kho', 
        i.SoLuong, 
        i.MaPhieu, 
        N'Hệ thống tự động ghi nhận khi lập chi tiết phiếu nhập'
    FROM inserted i;
END;
GO

-- Trigger 2: Tự động trừ tồn kho và ghi lịch sử khi XUẤT KHO
CREATE TRIGGER TRG_TuDongXuatKho
ON ChiTietPhieuXuatKho
AFTER INSERT
AS
BEGIN
    -- 1. Cập nhật trừ số dư tồn kho
    UPDATE h
    SET h.SoLuongTonKho = h.SoLuongTonKho - i.SoLuong
    FROM HangHoa h
    JOIN inserted i ON h.MaHang = i.MaHang;

    -- 2. Ghi vết vào Lịch Sử Tồn Kho
    INSERT INTO LichSuTonKho (MaHang, NgayGhiNhan, LoaiBienDong, SoLuongThayDoi, MaChungTu, GhiChu)
    SELECT 
        i.MaHang, 
        GETDATE(), 
        N'Xuất kho', 
        -i.SoLuong, -- Chuyển thành số âm để biểu thị xuất kho
        i.MaPhieu, 
        N'Hệ thống tự động ghi nhận khi lập chi tiết phiếu xuất'
    FROM inserted i;
END;
GO
-- 3.Các Stored Procedure (Xử Lý Nghiệp Vụ & Báo Cáo)
-- SP 1: Nghiệp vụ Lập phiếu Xuất kho (Kiểm tra điều kiện tồn kho trước khi lưu)
CREATE PROCEDURE SP_LapChiTietPhieuXuat
    @MaPhieu VARCHAR(20),
    @MaHang VARCHAR(20),
    @SoLuong INT,
    @DonGia DECIMAL(18,2)
AS
BEGIN
    -- Kiểm tra tồn kho khả dụng 
    DECLARE @TonKhoHienTai INT;
    SELECT @TonKhoHienTai = SoLuongTonKho FROM HangHoa WHERE MaHang = @MaHang;

    IF (@TonKhoHienTai < @SoLuong)
    BEGIN
        RAISERROR(N'Số lượng tồn kho thực tế không đủ để xuất hàng, vui lòng báo phòng mua hàng!', 16, 1);
        RETURN;
    END

    -- Nếu đủ điều kiện, chỉ cần INSERT. Trigger TRG_TuDongXuatKho sẽ tự động chạy để trừ tồn kho!
    INSERT INTO ChiTietPhieuXuatKho (MaPhieu, MaHang, SoLuong, DonGia)
    VALUES (@MaPhieu, @MaHang, @SoLuong, @DonGia);
END;
GO

-- SP 2: Báo cáo danh sách hàng hóa đang tồn kho dưới mức tối thiểu (Cần đặt bổ sung)
CREATE PROCEDURE SP_BaoCaoHangTonDuoiMucToiThieu
AS
BEGIN
    SELECT 
        h.MaHang AS 'Mã Hàng',
        h.TenHang AS 'Tên Hàng Hóa',
        h.DVT AS 'Đơn Vị Tính',
        h.HanMucTonToiThieu AS 'Hạn Mức Tối Thiểu',
        h.SoLuongTonKho AS 'Tồn Kho Hiện Tại',
        (h.HanMucTonToiThieu - h.SoLuongTonKho) AS 'Số Lượng Cần Bổ Sung'
    FROM HangHoa h
    WHERE h.SoLuongTonKho <= h.HanMucTonToiThieu
    ORDER BY [Số Lượng Cần Bổ Sung] DESC;
END;
GO

-- SP 3: Báo cáo Nhập - Xuất - Tồn theo kỳ hạn (Tháng/Quý)
CREATE PROCEDURE SP_BaoCaoNhapXuatTonTheoKy
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SELECT 
        h.MaHang,
        h.TenHang,
        h.SoLuongTonKho AS 'Tồn Kho Cuối Kỳ',
        ISNULL(SUM(ctn.SoLuong), 0) AS 'Tổng Nhập Trong Kỳ',
        ISNULL(SUM(ctx.SoLuong), 0) AS 'Tổng Xuất Trong Kỳ'
    FROM HangHoa h
    LEFT JOIN ChiTietPhieuNhapKho ctn ON h.MaHang = ctn.MaHang
    LEFT JOIN PhieuNhapKho pn ON ctn.MaPhieu = pn.MaPhieu AND pn.NgayLap BETWEEN @TuNgay AND @DenNgay
    LEFT JOIN ChiTietPhieuXuatKho ctx ON h.MaHang = ctx.MaHang
    LEFT JOIN PhieuXuatKho px ON ctx.MaPhieu = px.MaPhieu AND px.NgayLap BETWEEN @TuNgay AND @DenNgay
    GROUP BY h.MaHang, h.TenHang, h.SoLuongTonKho;
END;
GO
--- SP 4: lập phiếu xuất kho( dành cho các bộ phận yêu cầu xuất kho )
CREATE PROCEDURE SP_LapPhieuDeNghiXuat
    @MaDeNghi VARCHAR(20),
    @NgayDeNghi DATE,
    @LyDo NVARCHAR(255),
    @MaHang VARCHAR(20),
    @SoLuongYeuCau INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Tạo mới phiếu đề nghị với trạng thái mặc định là 'Chờ duyệt'
        -- Sử dụng IF NOT EXISTS để tránh lỗi nếu lập nhiều mặt hàng cho cùng 1 phiếu
        IF NOT EXISTS (SELECT 1 FROM PhieuDeNghiXuat WHERE MaDeNghi = @MaDeNghi)
        BEGIN
            INSERT INTO PhieuDeNghiXuat (MaDeNghi, NgayDeNghi, LyDo, TrangThai)
            VALUES (@MaDeNghi, @NgayDeNghi, @LyDo, N'Chờ duyệt');
        END

        -- 2. Thêm chi tiết mặt hàng cần xin xuất
        INSERT INTO ChiTietPhieuDeNghiXuat (MaDeNghi, MaHang, SoLuongYeuCau)
        VALUES (@MaDeNghi, @MaHang, @SoLuongYeuCau);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
-- SP 5:Thủ tục duyệt phiếu NHẬP kho
CREATE PROCEDURE SP_DuyetPhieuNhapKho
    @MaPhieu VARCHAR(20),
    @MaTruongKho VARCHAR(20) -- Mã nhân viên của người duyệt
AS
BEGIN
    UPDATE PhieuNhapKho
    SET MaNguoiDuyet = @MaTruongKho
    WHERE MaPhieu = @MaPhieu;
END;
GO

-- SP6:  Thủ tục duyệt phiếu XUẤT kho
CREATE PROCEDURE SP_DuyetPhieuXuatKho
    @MaPhieu VARCHAR(20),
    @MaTruongKho VARCHAR(20)
AS
BEGIN
    UPDATE PhieuXuatKho
    SET MaNguoiDuyet = @MaTruongKho
    WHERE MaPhieu = @MaPhieu;
    
    -- Tùy chọn: Đổi trạng thái của Phiếu Đề Nghị liên quan thành 'Đã hoàn tất'
    UPDATE PhieuDeNghiXuat
    SET TrangThai = N'Đã hoàn tất'
    WHERE MaDeNghi = (SELECT MaDeNghi FROM PhieuXuatKho WHERE MaPhieu = @MaPhieu);
END;
GO
-- SP 7: xử lý chênh lệch khi kiểm kê
CREATE PROCEDURE SP_XuLyChenhLechKiemKe
    @MaKiemKe VARCHAR(20),
    @MaHang VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @SoLuongThucTe INT;
        DECLARE @ChenhLech INT;

        -- 1. Lấy thông tin chênh lệch từ bảng ChiTietPhieuKiemKe
        SELECT 
            @SoLuongThucTe = SoLuongThucTe, 
            @ChenhLech = ChenhLech
        FROM ChiTietPhieuKiemKe
        WHERE MaKiemKe = @MaKiemKe AND MaHang = @MaHang;

        -- 2. Chỉ xử lý điều chỉnh nếu thực sự có chênh lệch (ChenhLech khác 0)
        IF (@ChenhLech <> 0)
        BEGIN
            -- Ghi đè số lượng tồn kho trên hệ thống bằng đúng số lượng đếm thực tế
            UPDATE HangHoa
            SET SoLuongTonKho = @SoLuongThucTe
            WHERE MaHang = @MaHang;

            -- Ghi vết thao tác này vào Lịch sử tồn kho để truy xuất báo cáo sau này
            INSERT INTO LichSuTonKho (MaHang, NgayGhiNhan, LoaiBienDong, SoLuongThayDoi, MaChungTu, GhiChu)
            VALUES (
                @MaHang, 
                GETDATE(), 
                N'Điều chỉnh kiểm kê', 
                @ChenhLech, 
                @MaKiemKe, 
                N'Hệ thống tự động điều chỉnh số dư do kiểm kê thực tế có chênh lệch'
            );
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


-- ====================================================================
-- PHẦN 1: DỮ LIỆU DANH MỤC (Thêm trước vì không có khóa ngoại)
-- ====================================================================

-- 1. Dữ liệu Bộ Phận (Dựa trên cơ cấu nhân sự)
INSERT INTO BoPhan (MaBoPhan, TenBoPhan, MoTa) VALUES 
('BP01', N'Phòng Quản lý Kho', N'Quản lý nhập xuất tồn'),
('BP02', N'Phòng Mua Hàng', N'Liên hệ nhà cung cấp'),
('BP03', N'Phòng Kinh Doanh', N'Bán hàng và phân phối'),
('BP04', N'Phòng Kế Toán', N'Thống kê và báo cáo');

-- 2. Dữ liệu Loại Hàng Hóa (FMCG)
INSERT INTO LoaiHangHoa (MaLoai, TenLoai) VALUES 
('LH01', N'Chăm sóc cá nhân'),
('LH02', N'Thực phẩm dinh dưỡng'),
('LH03', N'Gia vị - Thực phẩm'),
('LH04', N'Chất tẩy rửa');

-- 3. Dữ liệu Vị Trí Kho
INSERT INTO ViTriKho (MaViTri, TenViTri, TrangThai) VALUES 
('K1-T1', N'Kệ 1 - Tầng 1 (Khu A)', N'Đang sử dụng'),
('K1-T2', N'Kệ 1 - Tầng 2 (Khu A)', N'Đang sử dụng'),
('K2-T1', N'Kệ 2 - Tầng 1 (Khu B)', N'Đang sử dụng');

-- ====================================================================
-- PHẦN 2: DỮ LIỆU ĐỐI TÁC, NHÂN VIÊN & SẢN PHẨM
-- ====================================================================

-- 4. Dữ liệu Nhà Cung Cấp
INSERT INTO NhaCungCap (TenNCC, DiaChi, SDT, Email) 
VALUES (N'Unilever Việt Nam', N'Quận 7, TP.HCM', '02838123456', 'contact@unilever.com'),
 (N'Masan Consumer', N'Quận 1, TP.HCM', '02838123457', 'sales@masan.com'),
(N'Abbott Việt Nam', N'Quận 1, TP.HCM', '02838123458', 'info@abbott.com');

-- 5. Dữ liệu Nhân Viên (Có liên kết Bộ Phận)
INSERT INTO NhanVien (MaNV, HoTen, SDT, DiaChi, NgaySinh, MaBoPhan) VALUES 
('NV01', N'Nguyễn Văn Thủ', '0901234567', N'Bình Thạnh, TP.HCM', '1990-05-15', 'BP01'), -- Thủ kho
('NV02', N'Trần Thị Trưởng', '0901234568', N'Gò Vấp, TP.HCM', '1985-08-20', 'BP01'),   -- Trưởng kho
('NV03', N'Lê Mua Hàng', '0901234569', N'Quận 2, TP.HCM', '1992-10-10', 'BP02'),     -- Nhân viên mua hàng
('NV04', N'Phạm Kinh Doanh', '0901234570', N'Quận 3, TP.HCM', '1995-01-01', 'BP03'); -- Nhân viên kinh doanh

-- 6. Dữ liệu Tài Khoản
INSERT INTO TaiKhoan (TenDangNhap, MatKhau, VaiTro, TrangThai, MaNV) VALUES 
('thukho1', '123456', N'Thủ kho', N'Hoạt động', 'NV01'),
('truongkho', '123456', N'Trưởng kho', N'Hoạt động', 'NV02');

-- 7. Dữ liệu Hàng Hóa (FMCG theo đối tác)
-- Lưu ý: SoLuongTonKho ban đầu để 0, sau đó tạo phiếu nhập tự động tăng
INSERT INTO HangHoa (TenHang, DVT, SoLuongTonKho, QuyCach, HanMucTonToiThieu, MaLoai, MaViTri) 
VALUES (N'Dầu gội Clear Men', N'Chai', 150, N'650g/chai', 50, 'LH01', 'K1-T1'),
( N'Nước mắm Nam Ngư', N'Chai', 80, N'500ml/chai', 100, 'LH03', 'K1-T2'),
( N'Sữa bột Ensure Gold', N'Hộp', 200, N'850g/hộp', 30, 'LH02', 'K2-T1'),
(N'Bột giặt OMO', N'Bịch', 500, N'4.5kg/bịch', 150, 'LH04', 'K2-T1');

-- ====================================================================
-- PHẦN 3: DỮ LIỆU NGHIỆP VỤ (PHIẾU ĐỀ NGHỊ, NHẬP, XUẤT, KIỂM KÊ)
-- ====================================================================

-- 8. Dữ liệu Phiếu Đề Nghị Xuất (Từ phòng kinh doanh)
INSERT INTO PhieuDeNghiXuat (MaDeNghi, NgayDeNghi, LyDo, TrangThai) VALUES 
('DNX001', '2026-05-20', N'Xuất hàng giao đại lý Quận Bình Thạnh', N'Đã duyệt'),
('DNX002', '2026-05-22', N'Xuất hàng khuyến mãi siêu thị', N'Chờ duyệt');

INSERT INTO ChiTietPhieuDeNghiXuat (MaDeNghi, MaHang, SoLuongYeuCau) VALUES 
('DNX001', 'SP01', 20),
('DNX001', 'SP04', 50),
('DNX002', 'SP03', 10);

-- 9. Dữ liệu Phiếu Nhập Kho
INSERT INTO PhieuNhapKho (MaPhieu, NgayLap, MaNV, MaNCC, SoHoaDon, GhiChu, MaNguoiDuyet) VALUES 
('PN001', '2026-05-01', 'NV01', 'NCC01', 'HD_UNI_001', N'Nhập đủ hàng theo hóa đơn', 'NV02'),
('PN002', '2026-05-05', 'NV01', 'NCC02', 'HD_MASAN_02', N'Nhập nước mắm', 'NV02');

-- LƯU Ý: Nếu bạn ĐÃ TẠO TRIGGER cập nhật tồn kho ở bước trước, khi chạy 2 lệnh INSERT dưới đây, 
-- số lượng tồn kho của bảng HangHoa sẽ tự động được cộng thêm, và lịch sử sẽ được ghi lại.
INSERT INTO ChiTietPhieuNhapKho (MaPhieu, MaHang, SoLuong, DonGia) VALUES 
('PN001', 'SP01', 100, 120000),
('PN001', 'SP04', 300, 150000),
('PN002', 'SP02', 80, 25000);

-- 10. Dữ liệu Phiếu Xuất Kho
INSERT INTO PhieuXuatKho (MaPhieu, NgayLap, MaNV, MaDeNghi, BoPhanNhan, MucDich, MaNguoiDuyet) VALUES 
('PX001', '2026-05-21', 'NV01', 'DNX001', N'Phòng Kinh Doanh', N'Giao đại lý Bình Thạnh', 'NV02');

-- Nếu có TRIGGER, khi chạy lệnh này, tồn kho sẽ tự động giảm và lưu Lịch sử.
INSERT INTO ChiTietPhieuXuatKho (MaPhieu, MaHang, SoLuong, DonGia) VALUES 
('PX001', 'SP01', 20, 150000),
('PX001', 'SP04', 50, 180000);


-- 11. Dữ liệu Phiếu Kiểm Kê Hàng Hóa (Định kỳ cuối tháng)
INSERT INTO PhieuKiemKeHangHoa (MaKiemKe, NgayKiem, MaNV) VALUES 
('PKK_052026', '2026-05-31', 'NV01');

INSERT INTO ChiTietPhieuKiemKe (MaKiemKe, MaHang, SoLuongThucTe, ChenhLech, NguyenNhan) VALUES 
('PKK_052026', 'SP02', 78, -2, N'Vỡ móp trong quá trình di chuyển (thực tế 78, lý thuyết 80)');

-- 12. Dữ liệu Dự Báo (Mô phỏng AI dự đoán nhập hàng tháng 6)
INSERT INTO KetQuaDuBao (MaDuBao, DoChinhXac, NgayDuBao, SoLuongDuBao, MaHang) VALUES 
('DB_062026_1', 92.50, '2026-05-31', 500, 'SP04'),
('DB_062026_2', 88.00, '2026-05-31', 300, 'SP02');

EXEC SP_BaoCaoHangTonDuoiMucToiThieu;

SELECT T.TenDangNhap, T.VaiTro, N.HoTen  
                       FROM TaiKhoan T  
                       JOIN NhanVien N ON T.MaNV = N.MaNV  
                       WHERE T.TenDangNhap = 'thukho1' AND T.MatKhau = '123456'