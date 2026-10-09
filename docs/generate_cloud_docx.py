import os
import sys
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

import matplotlib
matplotlib.use('Agg')
matplotlib.rcParams['font.sans-serif'] = ['DejaVu Sans', 'Arial', 'Segoe UI']
matplotlib.rcParams['axes.unicode_minus'] = False
import matplotlib.pyplot as plt
import matplotlib.patches as patches

from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

DOCS_DIR = os.path.dirname(os.path.abspath(__file__))
IMG_DIR = os.path.join(DOCS_DIR, 'images')
os.makedirs(IMG_DIR, exist_ok=True)

# ---------------------------------------------------------------------------
# 1. HÀM VẼ CÁC SƠ ĐỒ CHUYÊN NGHIỆP THAY THẾ MERMAID
# ---------------------------------------------------------------------------

def draw_current_architecture():
    """Hình 1: Kiến trúc Hiện tại (Traditional / Local-First)"""
    fig, ax = plt.subplots(figsize=(10, 5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5)
    ax.axis('off')

    # Khung bao hệ thống truyền thống
    bg_frame = patches.FancyBboxPatch((0.2, 0.2), 9.6, 4.5, boxstyle="round,pad=0.15", fc='#F8F9FA', ec='#B0BEC5', lw=1.5, ls='--')
    ax.add_patch(bg_frame)
    ax.text(0.5, 4.4, "KIẾN TRÚC HIỆN TẠI: LOCAL-FIRST & MÁY CHỦ TRUYỀN THỐNG (ON-PREMISES)", fontsize=10, fontweight='bold', color='#455A64')

    # 1. Frontend
    box_fe = patches.FancyBboxPatch((0.6, 1.6), 2.4, 2.0, boxstyle="round,pad=0.1", fc='#E3F2FD', ec='#1976D2', lw=2)
    ax.add_patch(box_fe)
    ax.text(1.8, 3.0, "FRONTEND CLIENT", ha='center', va='center', fontsize=10.5, fontweight='bold', color='#0D47A1')
    ax.text(1.8, 2.2, "• Flutter App (Dart)\n• Mobile / Desktop UI\n• State Management\n• SfPdfViewer In-app", ha='center', va='center', fontsize=8.5, color='#1565C0')

    # 2. Database Local
    box_db = patches.FancyBboxPatch((4.0, 2.6), 2.5, 1.5, boxstyle="round,pad=0.1", fc='#E8F5E9', ec='#388E3C', lw=2)
    ax.add_patch(box_db)
    ax.text(5.25, 3.6, "DATABASE CỤC BỘ", ha='center', va='center', fontsize=10, fontweight='bold', color='#1B5E20')
    ax.text(5.25, 3.0, "• Drift ORM (SQLite)\n• Bảng Subjects, Docs\n• DeleteLogs (Tombstone)", ha='center', va='center', fontsize=8, color='#2E7D32')

    # 3. File Storage Local
    box_fs = patches.FancyBboxPatch((4.0, 0.6), 2.5, 1.5, boxstyle="round,pad=0.1", fc='#FFF3E0', ec='#F57C00', lw=2)
    ax.add_patch(box_fs)
    ax.text(5.25, 1.6, "FILE STORAGE CỤC BỘ", ha='center', va='center', fontsize=10, fontweight='bold', color='#E65100')
    ax.text(5.25, 1.0, "• Thư mục studyhub_files\n• Ổ cứng thiết bị / máy chủ\n• Quản lý file nhị phân tĩnh", ha='center', va='center', fontsize=8, color='#EF6C00')

    # 4. Backend Truyền thống
    box_be = patches.FancyBboxPatch((7.2, 1.6), 2.2, 2.0, boxstyle="round,pad=0.1", fc='#FFEBEE', ec='#D32F2F', lw=2)
    ax.add_patch(box_be)
    ax.text(8.3, 3.0, "BACKEND MÁY CHỦ", ha='center', va='center', fontsize=10, fontweight='bold', color='#B71C1C')
    ax.text(8.3, 2.2, "• Monolithic REST API\n• Máy chủ On-Premise/VPS\n• Xử lý cả API & File I/O\n• Dễ nghẽn cổ chai", ha='center', va='center', fontsize=8, color='#C62828')

    # Mũi tên kết nối
    ax.annotate("Đọc / Ghi\nMetadata", xy=(3.9, 3.3), xytext=(3.1, 3.0),
                arrowprops=dict(arrowstyle="<->", color='#2E7D32', lw=1.6), fontsize=8, ha='center', color='#1B5E20')
    ax.annotate("Lưu & Đọc\ntệp PDF/DOCX", xy=(3.9, 1.4), xytext=(3.1, 1.9),
                arrowprops=dict(arrowstyle="<->", color='#E65100', lw=1.6), fontsize=8, ha='center', color='#BF360C')
    ax.annotate("Gọi API truyền thống\n(Nếu có server trường)", xy=(7.1, 2.6), xytext=(6.6, 2.6),
                arrowprops=dict(arrowstyle="<->", color='#B71C1C', lw=1.5, ls='--'), fontsize=7.5, ha='center', color='#B71C1C')

    plt.title("HÌNH 1: SƠ ĐỒ KIẾN TRÚC HỆ THỐNG TRUYỀN THỐNG / CỤC BỘ (BEFORE CLOUD)", fontsize=11, fontweight='bold', pad=12)
    out_path = os.path.join(IMG_DIR, "cloud_arch_current.png")
    plt.tight_layout()
    plt.savefig(out_path, bbox_inches='tight')
    plt.close()
    return out_path


def draw_cloud_architecture():
    """Hình 2: Kiến trúc Tích hợp Cloud Tổng thể (Hybrid Cloud + Serverless)"""
    fig, ax = plt.subplots(figsize=(11, 7), dpi=300)
    ax.set_xlim(0, 11)
    ax.set_ylim(0, 7)
    ax.axis('off')

    # Khung phân tầng
    layers = [
        ("TẦNG CLIENT (LOCAL-FIRST EDGE)", 0.3, 4.7, 3.1, 1.9, '#E3F2FD', '#1976D2'),
        ("TẦNG MẠNG BIÊN & AN NINH (CDN / API GW)", 3.8, 4.7, 3.2, 1.9, '#F3E5F5', '#8E24AA'),
        ("TẦNG ĐỊNH DANH (AUTH)", 7.4, 4.7, 3.2, 1.9, '#FFF9C4', '#FBC02D'),
        ("TẦNG XỬ LÝ SERVERLESS (COMPUTE)", 3.8, 1.5, 3.2, 2.7, '#E8F5E9', '#388E3C'),
        ("TẦNG LƯU TRỮ ĐÁM MÂY (STORAGE & DATABASE)", 7.4, 0.6, 3.2, 3.6, '#FFF3E0', '#F57C00'),
    ]

    for title, x, y, w, h, bg, border in layers:
        frame = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.1", fc=bg, ec=border, lw=1.8)
        ax.add_patch(frame)
        ax.text(x + w/2, y + h - 0.25, title, ha='center', va='center', fontsize=8.5, fontweight='bold', color='#263238')

    # Chi tiết bên trong Tầng Client
    ax.text(1.85, 5.75, "StudyHub Flutter App", ha='center', va='center', fontsize=9.5, fontweight='bold', color='#0D47A1')
    ax.text(1.85, 5.25, "• Local Drift SQLite (Cache 0ms)\n• Local Filesystem Cache\n• Đọc tài liệu Offline 100%", ha='center', va='center', fontsize=8, color='#1565C0')

    # Chi tiết bên trong Tầng Mạng biên
    ax.text(5.4, 5.8, "Cloudflare CDN / AWS CloudFront", ha='center', va='center', fontsize=9, fontweight='bold', color='#4A148C')
    ax.text(5.4, 5.4, "• Edge Caching PDF (<30ms)\n• DDoS Protection & WAF Firewall", ha='center', va='center', fontsize=8, color='#6A1B9A')
    ax.text(5.4, 4.95, "AWS API Gateway (Reverse Proxy)", ha='center', va='center', fontsize=8.5, fontweight='bold', color='#4A148C')

    # Chi tiết bên trong Tầng Định danh
    ax.text(9.0, 5.75, "Google OAuth 2.0 / Cognito", ha='center', va='center', fontsize=9, fontweight='bold', color='#F57F17')
    ax.text(9.0, 5.25, "• Đăng nhập Email trường đại học\n• Cấp JWT Token truy cập an toàn\n• Quản lý quyền theo vai trò (RBAC)", ha='center', va='center', fontsize=8, color='#E65100')

    # Chi tiết bên trong Tầng Serverless
    ax.text(5.4, 3.7, "Document Service (Lambda / Run)", ha='center', va='center', fontsize=9, fontweight='bold', color='#1B5E20')
    ax.text(5.4, 3.3, "• Tạo Presigned URL cho Upload\n• Kiểm tra hợp lệ & Metadata", ha='center', va='center', fontsize=7.8, color='#2E7D32')
    ax.text(5.4, 2.5, "Sync Engine Service (Lambda)", ha='center', va='center', fontsize=9, fontweight='bold', color='#1B5E20')
    ax.text(5.4, 2.0, "• Xử lý đồng bộ 2 chiều (LWW)\n• Quản lý Tombstone DeleteLogs", ha='center', va='center', fontsize=7.8, color='#2E7D32')

    # Chi tiết bên trong Tầng Lưu trữ đám mây
    ax.text(9.0, 3.6, "Cloud Database (PostgreSQL)", ha='center', va='center', fontsize=9, fontweight='bold', color='#E65100')
    ax.text(9.0, 3.0, "• Supabase Managed DB / Aurora\n• Bảng Subjects, Documents\n• Realtime Event Stream", ha='center', va='center', fontsize=8, color='#BF360C')
    ax.text(9.0, 1.9, "Cloud Object Storage", ha='center', va='center', fontsize=9, fontweight='bold', color='#E65100')
    ax.text(9.0, 1.2, "• Cloudflare R2 / AWS S3\n• Lưu tệp PDF, DOCX, PPTX\n• Độ bền 99.999999999% (11 số 9)\n• Zero Egress Fee (với R2)", ha='center', va='center', fontsize=7.8, color='#BF360C')

    # Mũi tên kết nối
    # Client -> Auth
    ax.annotate("1. Xác thực Google", xy=(7.3, 5.7), xytext=(3.5, 5.9),
                arrowprops=dict(arrowstyle="->", color='#F57F17', lw=1.5), fontsize=8, color='#E65100')
    # Client -> API Gateway
    ax.annotate("2. Yêu cầu API", xy=(3.7, 5.0), xytext=(3.5, 5.0),
                arrowprops=dict(arrowstyle="->", color='#8E24AA', lw=1.5), fontsize=8, color='#6A1B9A')
    # API GW -> Compute
    ax.annotate("", xy=(5.4, 4.3), xytext=(5.4, 4.6), arrowprops=dict(arrowstyle="->", color='#388E3C', lw=1.5))
    # Compute -> DB & S3
    ax.annotate("3. Sinh Presigned URL", xy=(7.3, 1.9), xytext=(6.5, 2.8),
                arrowprops=dict(arrowstyle="->", color='#F57C00', lw=1.5), fontsize=7.5, color='#E65100')
    ax.annotate("4. Ghi Metadata", xy=(7.3, 3.2), xytext=(6.5, 3.3),
                arrowprops=dict(arrowstyle="->", color='#388E3C', lw=1.5), fontsize=7.5, color='#2E7D32')
    # Client -> S3 Direct Upload
    ax.annotate("5. UPLOAD TRỰC TIẾP (Presigned URL)", xy=(7.3, 1.5), xytext=(1.85, 1.2),
                arrowprops=dict(arrowstyle="->", color='#D32F2F', lw=2.2), fontsize=8.5, fontweight='bold', color='#B71C1C')
    # Client <- CDN Download
    ax.annotate("6. Tải PDF tốc độ cao qua Edge CDN", xy=(2.2, 4.6), xytext=(3.7, 4.6),
                arrowprops=dict(arrowstyle="<-", color='#0D47A1', lw=1.8), fontsize=8, fontweight='bold', color='#0D47A1')

    plt.title("HÌNH 2: SƠ ĐỒ KIẾN TRÚC TÍCH HỢP CLOUD TỔNG THỂ CHO STUDYHUB (HYBRID & SERVERLESS)", fontsize=11, fontweight='bold', pad=12)
    out_path = os.path.join(IMG_DIR, "cloud_arch_integrated.png")
    plt.tight_layout()
    plt.savefig(out_path, bbox_inches='tight')
    plt.close()
    return out_path


def draw_sequence_upload():
    """Hình 3: Sơ đồ Tuần tự Luồng Tải lên Trực tiếp (Direct-to-Cloud Upload Flow)"""
    fig, ax = plt.subplots(figsize=(10, 6), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')

    # Lifelines
    actors = [
        ("Sinh viên\n(User)", 1.0, '#E3F2FD', '#1976D2'),
        ("Flutter App\n(StudyHub)", 3.0, '#E1F5FE', '#0288D1'),
        ("Backend API\n(AWS Lambda)", 5.2, '#E8F5E9', '#388E3C'),
        ("Cloud DB\n(PostgreSQL)", 7.2, '#FFF9C4', '#FBC02D'),
        ("Cloud Storage\n(AWS S3 / R2)", 9.0, '#FFF3E0', '#F57C00')
    ]

    for title, x, bg, border in actors:
        box = patches.FancyBboxPatch((x - 0.7, 7.1), 1.4, 0.75, boxstyle="round,pad=0.08", fc=bg, ec=border, lw=1.5)
        ax.add_patch(box)
        ax.text(x, 7.47, title, ha='center', va='center', fontsize=8.5, fontweight='bold', color='#263238')
        ax.plot([x, x], [0.3, 7.1], color='#B0BEC5', lw=1.2, ls='--')

    # Các thông điệp tuần tự (Steps)
    steps = [
        (1, 1.0, 3.0, 6.4, "1. Chọn tệp PDF (30MB) & nhập tiêu đề", '#1976D2', False),
        (2, 3.0, 3.0, 5.8, "2. Ghi Drift SQLite (Trạng thái: Pending_Sync)", '#0288D1', True),
        (3, 3.0, 5.2, 5.2, "3. POST /documents/upload-ticket (Kèm Hash, Size)", '#388E3C', False),
        (4, 5.2, 9.0, 4.6, "4. Yêu cầu sinh Presigned PUT URL (TTL 10m)", '#F57C00', False),
        (5, 9.0, 5.2, 4.0, "5. Trả về Presigned URL có chữ ký", '#F57C00', False),
        (6, 5.2, 7.2, 3.4, "6. Tạo bản ghi Metadata (Status = Uploading)", '#FBC02D', False),
        (7, 5.2, 3.0, 2.8, "7. Trả Presigned URL & DocumentID về App", '#388E3C', False),
        (8, 3.0, 9.0, 2.1, "8. [HTTP PUT] UPLOAD FILE TRỰC TIẾP LÊN CLOUD", '#D32F2F', False),
        (9, 9.0, 3.0, 1.5, "9. Phản hồi HTTP 200 OK (Thành công)", '#388E3C', False),
        (10, 3.0, 5.2, 1.0, "10. PATCH /documents/{id}/confirm-upload", '#1976D2', False),
        (11, 5.2, 7.2, 0.6, "11. Cập nhật Status = Active (Hoàn tất)", '#388E3C', False),
    ]

    for num, x_from, x_to, y, text, col, is_self in steps:
        if is_self:
            # Vòng tự gọi
            ax.annotate(text, xy=(x_from, y), xytext=(x_from + 0.15, y),
                        fontsize=7.8, fontweight='bold', color=col)
            loop_box = patches.FancyBboxPatch((x_from, y - 0.15), 0.4, 0.3, boxstyle="round,pad=0.04", fc='#E1F5FE', ec='#0288D1', lw=1)
            ax.add_patch(loop_box)
        else:
            lw = 2.2 if num == 8 else 1.3
            ax.annotate("", xy=(x_to, y), xytext=(x_from, y),
                        arrowprops=dict(arrowstyle="->", color=col, lw=lw))
            mid_x = (x_from + x_to) / 2
            ax.text(mid_x, y + 0.13, text, ha='center', va='bottom', fontsize=7.8,
                    fontweight=('bold' if num == 8 else 'normal'), color=col)

    plt.title("HÌNH 3: SƠ ĐỒ TUẦN TỰ LUỒNG TẢI LÊN TRỰC TIẾP (PRESIGNED URL DIRECT-TO-CLOUD UPLOAD)", fontsize=11, fontweight='bold', pad=12)
    out_path = os.path.join(IMG_DIR, "cloud_seq_upload.png")
    plt.tight_layout()
    plt.savefig(out_path, bbox_inches='tight')
    plt.close()
    return out_path


def draw_roadmap():
    """Hình 4: Sơ đồ Lộ trình Triển khai 4 Giai đoạn"""
    fig, ax = plt.subplots(figsize=(10, 4.2), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 4.5)
    ax.axis('off')

    phases = [
        ("GIAI ĐOẠN 1 (Tuần 1-2)\nLƯU TRỮ ĐÁM MÂY",
         "• Thiết lập Cloudflare R2 / S3\n• Viết API cấp Presigned URL\n• Tích hợp tải lên/xuất file trên Flutter",
         0.4, 3.0, '#E3F2FD', '#1976D2'),
        ("GIAI ĐOẠN 2 (Tuần 3-4)\nDATABASE & ĐỒNG BỘ",
         "• Khởi tạo PostgreSQL (Supabase)\n• Hiện thực hóa Sync Engine hai chiều\n• Xử lý xung đột nhãn thời gian LWW",
         2.8, 3.0, '#E8F5E9', '#388E3C'),
        ("GIAI ĐOẠN 3 (Tuần 5-6)\nBẢO MẬT & MẠNG BIÊN",
         "• Cấu hình Cloudflare CDN Edge Cache\n• Tích hợp Google OAuth 2.0\n• Phân quyền RBAC & Bảo mật WAF",
         5.2, 3.0, '#FFF9C4', '#FBC02D'),
        ("GIAI ĐOẠN 4 (Tuần 7)\nKIỂM THỬ & KHỞI CHẠY",
         "• Kiểm thử tải cao (10.000 CCU)\n• Kiểm tra tính toàn vẹn khi Offline\n• Đóng gói và phát hành chính thức",
         7.6, 3.0, '#FFF3E0', '#F57C00')
    ]

    for title, desc, x, y, bg, border in phases:
        box = patches.FancyBboxPatch((x, 0.4), 2.0, 3.4, boxstyle="round,pad=0.1", fc=bg, ec=border, lw=1.8)
        ax.add_patch(box)
        ax.text(x + 1.0, 3.3, title, ha='center', va='center', fontsize=8.5, fontweight='bold', color='#1A237E')
        ax.plot([x + 0.15, x + 1.85], [2.8, 2.8], color=border, lw=1.2)
        ax.text(x + 0.15, 1.7, desc, ha='left', va='center', fontsize=7.8, color='#263238', linespacing=1.4)

    # Mũi tên kết nối giữa các giai đoạn
    for arrow_x in [2.45, 4.85, 7.25]:
        ax.annotate("", xy=(arrow_x + 0.3, 2.1), xytext=(arrow_x - 0.05, 2.1),
                    arrowprops=dict(arrowstyle="->", color='#37474F', lw=2.0))

    plt.title("HÌNH 4: LỘ TRÌNH 4 GIAI ĐOẠN CHUYỂN ĐỔI VÀ TÍCH HỢP CLOUD CHO STUDYHUB", fontsize=11, fontweight='bold', pad=12)
    out_path = os.path.join(IMG_DIR, "cloud_roadmap.png")
    plt.tight_layout()
    plt.savefig(out_path, bbox_inches='tight')
    plt.close()
    return out_path


# ---------------------------------------------------------------------------
# 2. HÀM TẠO FILE WORD ĐẸP, CHUẨN ĐỒ ÁN VÀ ĐẦY ĐỦ NỘI DUNG
# ---------------------------------------------------------------------------

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def create_styled_table(doc, headers, rows_data, col_widths=None):
    table = doc.add_table(rows=len(rows_data) + 1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False

    # Header Row
    hdr_cells = table.rows[0].cells
    for i, title in enumerate(headers):
        hdr_cells[i].text = title
        set_cell_background(hdr_cells[i], '1A365D') # Deep Navy Blue
        set_cell_margins(hdr_cells[i], top=120, bottom=120, left=140, right=140)
        p = hdr_cells[i].paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for run in p.runs:
            run.font.bold = True
            run.font.color.rgb = RGBColor(255, 255, 255)
            run.font.size = Pt(9.5)
            run.font.name = 'Times New Roman'

    # Data Rows
    for r_idx, row in enumerate(rows_data):
        row_cells = table.rows[r_idx + 1].cells
        bg_color = 'F7FAFC' if r_idx % 2 == 1 else 'FFFFFF'
        for c_idx, val in enumerate(row):
            row_cells[c_idx].text = str(val)
            set_cell_background(row_cells[c_idx], bg_color)
            set_cell_margins(row_cells[c_idx], top=90, bottom=90, left=120, right=120)
            p = row_cells[c_idx].paragraphs[0]
            # Can giua neu la cot dau hoac cot gia tien
            if c_idx == 0 or 'Chi phí' in headers[c_idx] or '$' in str(val):
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            else:
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            for run in p.runs:
                run.font.size = Pt(9)
                run.font.color.rgb = RGBColor(45, 55, 72)
                run.font.name = 'Times New Roman'

    # Thiet lap do rong cot neu co
    if col_widths and len(col_widths) == len(headers):
        for row in table.rows:
            for idx, width in enumerate(col_widths):
                row.cells[idx].width = Inches(width)

    p_space = doc.add_paragraph()
    p_space.paragraph_format.space_after = Pt(6)

def add_heading_1(doc, text):
    h = doc.add_paragraph()
    h.paragraph_format.space_before = Pt(14)
    h.paragraph_format.space_after = Pt(6)
    h.paragraph_format.keep_with_next = True
    run = h.add_run(text)
    run.font.name = 'Times New Roman'
    run.font.size = Pt(13.5)
    run.font.bold = True
    run.font.color.rgb = RGBColor(26, 54, 93) # Deep Blue
    return h

def add_heading_2(doc, text):
    h = doc.add_paragraph()
    h.paragraph_format.space_before = Pt(10)
    h.paragraph_format.space_after = Pt(4)
    h.paragraph_format.keep_with_next = True
    run = h.add_run(text)
    run.font.name = 'Times New Roman'
    run.font.size = Pt(12)
    run.font.bold = True
    run.font.color.rgb = RGBColor(43, 108, 176) # Accent Blue
    return h

def add_body_paragraph(doc, text, bold_prefix=None, space_after=5):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = 'Times New Roman'
        r_pre.font.size = Pt(11)
        r_pre.font.bold = True
        r_pre.font.color.rgb = RGBColor(26, 32, 44)
    r_body = p.add_run(text)
    r_body.font.name = 'Times New Roman'
    r_body.font.size = Pt(11)
    r_body.font.color.rgb = RGBColor(45, 55, 72)
    return p

def add_figure(doc, img_path, caption_text, width_inches=6.0):
    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_before = Pt(8)
    p_img.paragraph_format.space_after = Pt(4)
    run = p_img.add_run()
    run.add_picture(img_path, width=Inches(width_inches))

    p_cap = doc.add_paragraph()
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cap.paragraph_format.space_after = Pt(10)
    r_cap = p_cap.add_run(caption_text)
    r_cap.font.name = 'Times New Roman'
    r_cap.font.size = Pt(9.5)
    r_cap.font.italic = True
    r_cap.font.bold = True
    r_cap.font.color.rgb = RGBColor(74, 85, 104)

def build_full_cloud_word_document():
    doc = Document()

    # Thiết lập lề chuẩn đồ án A4 (Trái 3cm, Phải 2cm, Trên 2cm, Dưới 2cm)
    for section in doc.sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(0.8)

    # -------------------------------------------------------------
    # TRANG TIÊU ĐỀ & KHỐI THÔNG TIN
    # -------------------------------------------------------------
    p_univ = doc.add_paragraph()
    p_univ.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_univ.paragraph_format.space_after = Pt(2)
    r_u = p_univ.add_run("BỘ GIÁO DỤC VÀ ĐÀO TẠO — TRƯỜNG ĐẠI HỌC")
    r_u.font.name = 'Times New Roman'
    r_u.font.size = Pt(12)
    r_u.font.bold = True
    r_u.font.color.rgb = RGBColor(74, 85, 104)

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(18)
    r_s = p_sub.add_run("KHOA CÔNG NGHỆ THÔNG TIN & TRUYỀN THÔNG")
    r_s.font.name = 'Times New Roman'
    r_s.font.size = Pt(11)
    r_s.font.bold = True
    r_s.font.color.rgb = RGBColor(113, 128, 150)

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_after = Pt(6)
    r_t = p_title.add_run("BÁO CÁO KỸ THUẬT VÀ ĐỒ ÁN MÔN HỌC")
    r_t.font.name = 'Times New Roman'
    r_t.font.size = Pt(13)
    r_t.font.bold = True
    r_t.font.color.rgb = RGBColor(43, 108, 176)

    p_maintitle = doc.add_paragraph()
    p_maintitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_maintitle.paragraph_format.space_after = Pt(14)
    r_mt = p_maintitle.add_run("PHÂN TÍCH VÀ LẬP PHƯƠNG ÁN TÍCH HỢP CLOUD\nCHO HỆ THỐNG QUẢN LÝ TÀI LIỆU HỌC TẬP (STUDYHUB)")
    r_mt.font.name = 'Times New Roman'
    r_mt.font.size = Pt(16)
    r_mt.font.bold = True
    r_mt.font.color.rgb = RGBColor(26, 54, 93)

    # Khung tóm tắt thông tin
    info_table = doc.add_table(rows=3, cols=2)
    info_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    info_data = [
        ("Học phần / Môn học:", "Phát triển Ứng dụng Di động & Điện toán Đám mây"),
        ("Đối tượng khảo sát:", "Hệ thống Quản lý Tài liệu Học tập Thông minh StudyHub (Flutter / Drift)"),
        ("Chủ đề nghiên cứu:", "Chuyển đổi từ mô hình Local / On-Premise sang Hybrid Cloud & Serverless")
    ]
    for idx, (label, val) in enumerate(info_data):
        c0 = info_table.rows[idx].cells[0]
        c1 = info_table.rows[idx].cells[1]
        c0.width = Inches(2.2)
        c1.width = Inches(4.3)
        set_cell_background(c0, 'EDF2F7')
        set_cell_background(c1, 'F7FAFC')
        set_cell_margins(c0, 60, 60, 100, 100)
        set_cell_margins(c1, 60, 60, 100, 100)
        p0 = c0.paragraphs[0]
        p1 = c1.paragraphs[0]
        r0 = p0.add_run(label)
        r0.font.bold = True
        r0.font.size = Pt(10)
        r0.font.name = 'Times New Roman'
        r1 = p1.add_run(val)
        r1.font.size = Pt(10)
        r1.font.name = 'Times New Roman'

    p_sp = doc.add_paragraph()
    p_sp.paragraph_format.space_after = Pt(14)

    # -------------------------------------------------------------
    # 1. TỔNG QUAN HỆ THỐNG
    # -------------------------------------------------------------
    add_heading_1(doc, "1. TỔNG QUAN HỆ THỐNG VÀ BỐI CẢNH DỰ ÁN")
    add_body_paragraph(doc,
        "StudyHub là ứng dụng quản lý tài liệu học tập toàn diện, được thiết kế chuyên biệt cho sinh viên và giảng viên đại học. Ứng dụng cho phép phân loại tài liệu theo từng môn học, quản lý đa định dạng (PDF, DOCX, PPTX, Web URL), tích hợp trình xem trước tài liệu PDF trực tiếp và cơ chế đánh dấu sao các học liệu quan trọng.",
        bold_prefix="Bối cảnh hệ thống: ")
    add_body_paragraph(doc,
        "Hiện tại, ứng dụng được phát triển trên nền tảng Flutter đa nền tảng theo triết lý kiến trúc Local-First lấy cảm hứng từ Cashew App, lưu trữ dữ liệu tại chỗ bằng Drift ORM (SQLite) và bộ nhớ máy tính/điện thoại. Tuy nhiên, khi nhu cầu học tập trực tuyến tăng cao, người dùng cần truy cập kho tài liệu đồng bộ trên nhiều thiết bị (điện thoại, máy tính bảng, máy tính cá nhân), chia sẻ đề cương với bạn cùng lớp và bảo vệ kho tài liệu an toàn trước nguy cơ mất thiết bị.",
        bold_prefix="Động lực chuyển đổi: ")
    add_body_paragraph(doc,
        "Mục tiêu của đề tài là xây dựng một phương án kiến trúc điện toán đám mây (Cloud Computing) toàn diện nhằm: (1) Mở rộng kho lưu trữ không giới hạn; (2) Giải quyết triệt để các rủi ro mất mát dữ liệu; (3) Tối ưu hóa băng thông tải về với mạng phân phối nội dung CDN; và (4) Đảm bảo an toàn bảo mật dữ liệu với chi phí vận hành tối thiểu.",
        bold_prefix="Mục tiêu phương án: ")

    # -------------------------------------------------------------
    # 2. PHÂN TÍCH CÁC THÀNH PHẦN CỐT LÕI
    # -------------------------------------------------------------
    add_heading_1(doc, "2. PHÂN TÍCH CÁC THÀNH PHẦN CỐT LÕI CỦA HỆ THỐNG HIỆN TẠI")
    add_body_paragraph(doc, "Hệ thống quản lý tài liệu trước khi chuyển đổi bao gồm 4 thành phần trụ cột sau đây:")

    add_body_paragraph(doc,
        "Được xây dựng bằng ngôn ngữ Dart trên nền tảng Flutter 3.x, hỗ trợ Android, iOS, Windows, macOS và Web. Tầng giao diện tuân thủ quy chuẩn thiết kế Material 3, quản lý trạng thái bằng Riverpod/Provider, tích hợp trực tiếp thư viện SfPdfViewer để xem tài liệu không cần phần mềm thứ ba. Do tuân thủ cấu trúc phân lớp Clean Architecture, tầng UI hoàn toàn độc lập với nguồn dữ liệu, mang lại khả năng chuyển đổi rất cao.",
        bold_prefix="2.1. Frontend (Giao diện người dùng): ")

    add_body_paragraph(doc,
        "Ở mô hình hiện tại, logic xử lý nghiệp vụ chạy trực tiếp trên thiết bị client (Client-Driven Local Logic). Trong mô hình máy chủ truyền thống tương đương, backend là ứng dụng Monolithic REST API (Node.js/Spring Boot) cài đặt trên máy chủ cố định, vừa tiếp nhận truy vấn dữ liệu vừa kiêm nhiệm nhận và phân phối các tệp tin nhị phân nặng nề.",
        bold_prefix="2.2. Backend (Tầng xử lý nghiệp vụ): ")

    add_body_paragraph(doc,
        "Ứng dụng hiện sử dụng cơ sở dữ liệu nhúng Drift (SQLite) lưu trữ cục bộ trên máy người dùng. Cấu trúc dữ liệu bao gồm bảng Subjects (Môn học), bảng Documents (Metadata tài liệu, liên kết đường dẫn tệp, cờ ghim), và bảng DeleteLogs (Tombstone pattern ghi nhận vết bản ghi đã xóa để phục vụ đồng bộ).",
        bold_prefix="2.3. Database (Cơ sở dữ liệu): ")

    add_body_paragraph(doc,
        "Quản lý tệp nhị phân thông qua hệ thống tệp cục bộ (Local File System) trong thư mục riêng studyhub_files trên ổ cứng thiết bị hoặc máy chủ vật lý.",
        bold_prefix="2.4. File Storage (Lưu trữ tệp tin): ")

    # Chèn Sơ đồ 1
    current_arch_img = draw_current_architecture()
    add_figure(doc, current_arch_img, "Hình 1: Sơ đồ kiến trúc hệ thống hiện tại trên hạ tầng truyền thống / cục bộ", width_inches=6.2)

    # -------------------------------------------------------------
    # 3. XÁC ĐỊNH ĐIỂM NGHẼN VÀ HẠN CHẾ
    # -------------------------------------------------------------
    add_heading_1(doc, "3. XÁC ĐỊNH ĐIỂM NGHẼN VÀ HẠN CHẾ TRÊN HẠ TẦNG TRUYỀN THỐNG")
    add_body_paragraph(doc, "Qua khảo sát thực tế vận hành trên hạ tầng máy chủ truyền thống hoặc lưu trữ máy đơn lẻ, hệ thống bộc lộ 5 điểm nghẽn nghiêm trọng:")

    bottleneck_headers = ["Thành phần", "Điểm nghẽn trên hạ tầng truyền thống", "Hậu quả thực tế đối với ứng dụng"]
    bottleneck_rows = [
        ["Lưu trữ\n(Storage)",
         "Dung lượng ổ cứng máy chủ hoặc thiết bị có giới hạn cứng. Khi số lượng slide bài giảng, đề thi và sách giáo trình tăng cao, ổ cứng nhanh chóng bị đầy. Nâng cấp phải tắt máy chủ (Downtime).",
         "Ứng dụng báo lỗi đầy bộ nhớ, sinh viên không thể tải thêm tài liệu vào mùa thi."],
        ["Độ bền dữ liệu\n(Durability)",
         "Tồn tại Điểm lỗi đơn lẻ (Single Point of Failure - SPOF). Nếu ổ cứng bị hỏng hoặc thiết bị bị mất, toàn bộ dữ liệu bị mất vĩnh viễn do thiếu cơ chế sao lưu phân tán đa vùng.",
         "Mất mát toàn bộ kho tài liệu, ghi chú và đề cương mà sinh viên tích lũy qua nhiều kỳ."],
        ["Băng thông\n(Bandwidth)",
         "Máy chủ truyền thống phải gánh đồng thời cả xử lý logic API lẫn truyền tải file nhị phân dung lượng lớn. Băng thông mạng đường truyền cố định dễ bị nghẽn mạng.",
         "Hiện tượng nghẽn cổ chai: Hàng trăm sinh viên cùng tải đề cương trước giờ thi khiến server quá tải, tải tệp bị gián đoạn."],
        ["Chi phí\n(CapEx vs OpEx)",
         "Chi phí đầu tư ban đầu mua máy chủ lớn (CapEx), kèm theo tiền điện, điều hòa, bảo trì định kỳ 24/7 kể cả trong kỳ nghỉ hè khi không có người dùng.",
         "Chi phí vận hành và bảo trì máy chủ quá đắt đỏ so với một dự án phục vụ học tập."],
        ["Bảo mật\n(Security)",
         "Đường dẫn tệp tĩnh dễ bị dò quét trái phép. Dữ liệu trên ổ cứng không được mã hóa ở trạng thái nghỉ (At-Rest), thiếu cơ chế phân quyền truy cập chi tiết (RBAC).",
         "Sinh viên có thể vô tình xem hoặc tải tài liệu nội bộ, đề thi bí mật của giảng viên."]
    ]
    create_styled_table(doc, bottleneck_headers, bottleneck_rows, col_widths=[1.4, 2.7, 2.4])

    # -------------------------------------------------------------
    # 4. LỰA CHỌN MÔ HÌNH VÀ DỊCH VỤ CLOUD
    # -------------------------------------------------------------
    add_heading_1(doc, "4. LỰA CHỌN MÔ HÌNH VÀ DỊCH VỤ ĐIỆN TOÁN ĐÁM MÂY PHÙ HỢP")
    add_heading_2(doc, "4.1. Lựa chọn mô hình triển khai: HYBRID CLOUD (Đám mây lai kết hợp Local-First)")
    add_body_paragraph(doc,
        "Đề tài đề xuất lựa chọn mô hình HYBRID CLOUD kết hợp triết lý LOCAL-FIRST thay vì chuyển đổi 100% lên Public Cloud thuần túy hay duy trì Private Cloud:",
        bold_prefix="Đề xuất kiến trúc: ")
    add_body_paragraph(doc,
        "1. Phía Thiết bị người dùng (Edge/Client): Giữ nguyên cơ sở dữ liệu Drift SQLite và bộ nhớ đệm tệp cục bộ trên máy. Nhờ đó, ứng dụng đạt độ trễ phản hồi tức thì 0ms, sinh viên vẫn có thể mở đọc tài liệu học tập ngay cả khi mất kết nối mạng, ngồi trong thư viện tầng hầm hoặc trên xe bus.\n"
        "2. Phía Đám mây công cộng (Public Cloud): Tận dụng hạ tầng đám mây toàn cầu để lưu trữ kho tài liệu khổng lồ (Object Storage), quản lý xác thực tập trung và đồng bộ hóa dữ liệu hai chiều khi thiết bị có kết nối mạng.\n"
        "3. Mô hình dịch vụ: Áp dụng Serverless (FaaS - Function as a Service) kết hợp PaaS (Platform as a Service) để loại bỏ hoàn toàn gánh nặng quản trị hệ điều hành và phần cứng (NoOps).")

    add_heading_2(doc, "4.2. Lựa chọn các dịch vụ Cloud cụ thể")
    service_headers = ["Thành phần", "Dịch vụ được chọn", "Dịch vụ thay thế", "Lý do lựa chọn tối ưu cho StudyHub"]
    service_rows = [
        ["Cloud Storage\n(Lưu trữ tệp)",
         "Cloudflare R2 / AWS S3",
         "Google Cloud Storage, Azure Blob Storage",
         "• Độ bền dữ liệu 99.999999999% (11 số 9).\n• Cloudflare R2 tương thích S3 API nhưng MIỄN PHÍ 100% BĂNG THÔNG TẢI RA (Zero Egress Fee).\n• Hỗ trợ cơ chế Presigned URL."],
        ["Mạng CDN\n(Phân phối tệp)",
         "Cloudflare CDN / AWS CloudFront",
         "Fastly, Akamai",
         "• Bộ nhớ đệm tài liệu tại Edge Server đặt ở Hà Nội và TP.HCM.\n• Giảm thời gian mở tệp PDF từ vài giây xuống < 30ms."],
        ["Database Đám mây",
         "Supabase PostgreSQL\n(Managed DB)",
         "AWS RDS Aurora, Google Firestore",
         "• Chuẩn SQL quan hệ, bảo toàn tính toàn vẹn ACID.\n• Cung cấp sẵn cơ chế Realtime Webhook hỗ trợ đồng bộ dữ liệu tức thì."],
        ["Backend API\n(Xử lý nghiệp vụ)",
         "AWS Lambda / Google Cloud Run",
         "Node.js trên VPS, Heroku",
         "• Serverless: Chi phí = $0 khi không có người dùng.\n• Tự động co giãn theo mùa thi cử mà không cần can thiệp."],
        ["Xác thực (Auth)",
         "Google OAuth 2.0 / Firebase Auth",
         "AWS Cognito, Auth0",
         "• Đăng nhập 1 chạm an toàn bằng Email sinh viên trường đại học.\n• Tích hợp cơ chế cấp Token JWT ngắn hạn."]
    ]
    create_styled_table(doc, service_headers, service_rows, col_widths=[1.3, 1.6, 1.4, 2.2])

    # -------------------------------------------------------------
    # 5. THIẾT KẾ KIẾN TRÚC TÍCH HỢP CLOUD VÀ LUỒNG DỮ LIỆU
    # -------------------------------------------------------------
    add_heading_1(doc, "5. THIẾT KẾ KIẾN TRÚC TÍCH HỢP CLOUD VÀ LUỒNG DỮ LIỆU")
    add_body_paragraph(doc,
        "Kiến trúc tích hợp Cloud của StudyHub được thiết kế theo 4 phân tầng độc lập, đảm bảo tính sẵn sàng cao, bảo mật nhiều lớp và khả năng mở rộng đàn hồi:")

    # Chèn Sơ đồ 2
    cloud_arch_img = draw_cloud_architecture()
    add_figure(doc, cloud_arch_img, "Hình 2: Sơ đồ kiến trúc tích hợp Cloud tổng thể cho StudyHub (Hybrid Cloud & Serverless)", width_inches=6.3)

    add_heading_2(doc, "5.1. Luồng dữ liệu tải lên trực tiếp (Direct-to-Cloud Upload Flow)")
    add_body_paragraph(doc,
        "Một trong những điểm đột phá của kiến trúc là loại bỏ luồng tải tệp nhị phân qua máy chủ Backend. Thay vào đó, hệ thống sử dụng kỹ thuật Presigned URL (URL có chữ ký mật mã có thời hạn) để client đẩy tệp trực tiếp lên Cloud Object Storage:")
    add_body_paragraph(doc,
        "• Bước 1: Người dùng chọn tệp tài liệu PDF (ví dụ 30MB) và nhập tiêu đề môn học trên ứng dụng.\n"
        "• Bước 2: Ứng dụng lưu bản sao tệp vào Local Storage và ghi một bản ghi tạm vào Drift SQLite (Pending_Sync).\n"
        "• Bước 3: Ứng dụng gửi yêu cầu POST /documents/upload-ticket (kèm tên file, kích thước, mã băm MD5) tới API Gateway.\n"
        "• Bước 4: Backend Lambda xác thực JWT Token và gọi SDK Cloud Storage để sinh một Presigned PUT URL có thời hạn hiệu lực 10 phút.\n"
        "• Bước 5: Backend tạo bản ghi Metadata với trạng thái Uploading trong Cloud PostgreSQL và trả Presigned URL về cho ứng dụng.\n"
        "• Bước 6: Ứng dụng thực hiện HTTP PUT stream trực tiếp 30MB dữ liệu tệp lên Cloud Storage (hoàn toàn bỏ qua Backend).\n"
        "• Bước 7: Cloud Storage lưu trữ an toàn và phản hồi mã HTTP 200 OK.\n"
        "• Bước 8: Ứng dụng gọi PATCH /documents/{id}/confirm-upload để Backend cập nhật trạng thái Metadata sang Active.\n"
        "• Bước 9: Ứng dụng cập nhật trạng thái SQLite cục bộ sang isSynced = true. Hoàn tất quá trình tải lên.")

    # Chèn Sơ đồ 3
    upload_seq_img = draw_sequence_upload()
    add_figure(doc, upload_seq_img, "Hình 3: Sơ đồ tuần tự luồng tải lên trực tiếp (Presigned URL Direct-to-Cloud Upload)", width_inches=6.2)

    add_heading_2(doc, "5.2. Luồng dữ liệu tải về và tăng tốc qua CDN (Download Flow)")
    add_body_paragraph(doc,
        "Khi sinh viên mở xem tài liệu trên một thiết bị mới, ứng dụng sẽ ưu tiên tìm trong bộ nhớ đệm máy (Local Cache). Nếu chưa có, ứng dụng gửi yêu cầu tải qua đường dẫn CDN Edge. Nếu tài liệu đã được người khác tải gần đây (Cache Hit), Cloudflare Edge trả về tức thì với độ trễ dưới 30ms. Nếu chưa có trên Edge (Cache Miss), CDN tự động kéo tệp từ Object Storage gốc, vừa trả về cho ứng dụng vừa lưu một bản sao trên Edge cho các lượt truy cập sau.")

    add_heading_2(doc, "5.3. Luồng đồng bộ hai chiều và giải quyết xung đột (Sync Flow)")
    add_body_paragraph(doc,
        "Ứng dụng kế thừa bảng DeleteLogs (Tombstone pattern) và trường dateTimeModified của kiến trúc Cashew. Khi thiết bị kết nối mạng trở lại, Sync Service đối chiếu nhãn thời gian giữa máy client và máy chủ đám mây, áp dụng thuật toán Last-Write-Wins (LWW) để tự động hợp nhất dữ liệu, bảo đảm tài liệu đã xóa trên một máy sẽ tự động đồng bộ xóa trên toàn bộ các thiết bị còn lại.")

    # -------------------------------------------------------------
    # 6. BẢNG SO SÁNH TOÀN DIỆN
    # -------------------------------------------------------------
    add_heading_1(doc, "6. BẢNG SO SÁNH TOÀN DIỆN GIỮA MÔ HÌNH TRUYỀN THỐNG VÀ CLOUD")
    add_body_paragraph(doc, "Dưới đây là bảng đối sánh chi tiết trên 6 khía cạnh kỹ thuật cốt lõi giữa hai mô hình kiến trúc:")

    compare_headers = ["Tiêu chí so sánh", "Mô hình Truyền thống (On-Premises / Local)", "Mô hình Tích hợp Cloud (Hybrid & Serverless)"]
    compare_rows = [
        ["1. Khả năng mở rộng\n(Scalability)",
         "Bị giới hạn cứng bởi dung lượng ổ cứng và cấu hình RAM/CPU của một máy chủ cố định. Nâng cấp phức tạp, phải tắt máy gây gián đoạn dịch vụ.",
         "Mở rộng tự động và đàn hồi. Object Storage lưu trữ hàng triệu tài liệu mà không cần can thiệp. Backend tự động co giãn từ 1 lên 1000 instances."],
        ["2. Độ bền & Sẵn sàng\n(Durability & SLA)",
         "Rủi ro mất dữ liệu rất cao (Điểm lỗi đơn lẻ - SPOF). Nếu ổ cứng bị chập cháy hoặc mất thiết bị là mất trắng tài liệu. SLA dưới 99%.",
         "Độ bền dữ liệu đạt 99.999999999% (11 số 9) nhờ tự động nhân bản tại tối thiểu 3 vùng khả dụng (Availability Zones). SLA 99.95%."],
        ["3. Hiệu năng & Tốc độ\n(Latency & I/O)",
         "Dễ nghẽn cổ chai File I/O khi hàng trăm người cùng tải file. Tốc độ tải phụ thuộc vào đường truyền mạng vật lý của nơi đặt máy chủ.",
         "Cực nhanh nhờ CDN Edge Caching đưa tài liệu về máy chủ gần sinh viên nhất (< 30ms). Direct Upload giải phóng 100% băng thông server."],
        ["4. Chi phí đầu tư\n(Cost Structure)",
         "Chi phí cố định ban đầu cao (CapEx cho máy chủ, phòng lạnh, UPS). Lãng phí tài nguyên vào ban đêm và kỳ nghỉ hè khi ít sinh viên truy cập.",
         "Chi trả linh hoạt theo lượng dùng thực tế (OpEx - Pay-as-you-go). Ban đêm không có người truy cập thì chi phí Serverless = $0."],
        ["5. Quản trị & Vận hành\n(DevOps / NoOps)",
         "Tốn nhiều nhân sự cài đặt, vá lỗ hổng hệ điều hành, cấu hình firewall, thay thế ổ đĩa hỏng định kỳ.",
         "Managed Services / NoOps: Nhà cung cấp Cloud chịu trách nhiệm hạ tầng vật lý. Đội ngũ chỉ tập trung phát triển tính năng."],
        ["6. Trải nghiệm Offline",
         "Chạy được trên một máy đơn lẻ nhưng dữ liệu bị cô lập, không thể đồng bộ sang thiết bị khác nếu không có server.",
         "Kết hợp hoàn hảo: Vẫn mở đọc tài liệu offline mượt mà với SQLite, tự động đồng bộ tức thì lên đám mây khi có Internet."]
    ]
    create_styled_table(doc, compare_headers, compare_rows, col_widths=[1.5, 2.5, 2.5])

    # -------------------------------------------------------------
    # 7. ĐÁNH GIÁ TÁC ĐỘNG
    # -------------------------------------------------------------
    add_heading_1(doc, "7. ĐÁNH GIÁ TÁC ĐỘNG VỀ BẢO MẬT, CHI PHÍ VÀ HIỆU SUẤT")

    add_heading_2(doc, "7.1. Đánh giá tác động về Bảo mật (Security Impact)")
    add_body_paragraph(doc,
        "1. Mã hóa dữ liệu hai lớp: Sử dụng giao thức HTTPS / TLS 1.3 bảo vệ dữ liệu khi truyền tải (In-Transit). Toàn bộ tệp PDF/DOCX trên Cloud Storage và dữ liệu PostgreSQL được mã hóa tự động chuẩn AES-256 ở trạng thái nghỉ (At-Rest).\n"
        "2. Đóng kín quyền truy cập công khai (Block Public Access): Bucket Cloudflare R2 / AWS S3 được khóa 100%, không cấp quyền đọc công khai ra ngoài Internet.\n"
        "3. Kiểm soát quyền truy cập bằng Presigned URL: Tài liệu chỉ có thể tải qua đường dẫn ký số tạm thời có thời hạn sống ngắn (5 - 10 phút), ngăn chặn hoàn toàn việc chia sẻ trộm đường link ra ngoài.\n"
        "4. Tường lửa biên (Edge WAF & DDoS): Tích hợp Cloudflare WAF tự động ngăn chặn các đợt tấn công từ chối dịch vụ (DDoS) và quét lỗ hổng SQL Injection / XSS.")

    add_heading_2(doc, "7.2. Đánh giá tác động về Chi phí (Cost Impact & TCO)")
    add_body_paragraph(doc,
        "Phân tích Tổng chi phí sở hữu (Total Cost of Ownership - TCO) cho kịch bản quy mô 10.000 sinh viên hoạt động hàng tháng (MAU), lưu trữ 500 GB tài liệu học tập (khoảng 50.000 tệp) và phát sinh 1.5 TB lưu lượng tải về:")

    cost_headers = ["Thành phần dịch vụ", "Cách tính toán chi phí", "Chi phí ước tính / Tháng"]
    cost_rows = [
        ["Storage (Cloudflare R2)", "10 GB đầu miễn phí; 490 GB x $0.015 / GB", "$7.35"],
        ["Data Egress (Băng thông tải ra)", "Cloudflare R2 miễn phí 100% Egress (Zero Egress)", "$0.00 (Tiết kiệm ~$130)"],
        ["Cloud Database (Supabase Pro)", "Gói Pro: 8GB Database, Daily Backups, Realtime", "$25.00"],
        ["Serverless API (AWS Lambda)", "2.000.000 requests/tháng (1M miễn phí, 1M x $0.20)", "$0.20"],
        ["CDN & SSL (Cloudflare)", "Gói Free Plan tích hợp sẵn SSL và DDoS Shield", "$0.00"],
        ["TỔNG CỘNG HÀNG THÁNG", "Chi phí vận hành trọn gói cho 10.000 sinh viên", "~$32.55 / tháng (~800.000 VNĐ)"]
    ]
    create_styled_table(doc, cost_headers, cost_rows, col_widths=[1.8, 3.2, 1.5])
    add_body_paragraph(doc,
        "Nhận xét kinh tế: So với việc đầu tư một máy chủ vật lý ban đầu (từ 25 - 40 triệu VNĐ) kèm theo tiền điện, bảo trì và đường truyền mạng cố định (> 2.000.000 VNĐ/tháng), giải pháp Cloud giúp tiết kiệm hơn 70% tổng chi phí vận hành và loại bỏ hoàn toàn rủi ro khấu hao thiết bị.",
        bold_prefix="Hiệu quả kinh tế: ")

    add_heading_2(doc, "7.3. Đánh giá tác động về Hiệu suất (Performance Impact)")
    add_body_paragraph(doc,
        "• Độ trễ tương tác (Interaction Latency): Đạt 0ms cho các thao tác tìm kiếm, lọc môn học, duyệt danh mục nhờ cơ chế Local-First chạy trực tiếp trên SQLite máy người dùng.\n"
        "• Thời gian tải tài liệu: Nhờ bộ nhớ đệm Cloudflare Edge Caching đặt tại Việt Nam, thời gian mở tệp PDF giảm mạnh từ 3 - 5 giây xuống dưới 200ms.\n"
        "• Thông lượng hệ thống (Throughput): Luồng Direct Upload giải phóng toàn bộ tài nguyên CPU và RAM của máy chủ API, giúp hệ thống chịu tải mượt mà trên 10.000 yêu cầu đồng thời (CCU) trong mùa thi.")

    # -------------------------------------------------------------
    # 8. LỘ TRÌNH CHUYỂN ĐỔI VÀ KẾT LUẬN
    # -------------------------------------------------------------
    add_heading_1(doc, "8. LỘ TRÌNH CHUYỂN ĐỔI VÀ KẾT LUẬN")
    add_body_paragraph(doc,
        "Để quá trình chuyển đổi diễn ra an toàn, không làm gián đoạn việc học tập của sinh viên, dự án đề xuất lộ trình triển khai gồm 4 giai đoạn cụ thể:")

    # Chèn Sơ đồ 4
    roadmap_img = draw_roadmap()
    add_figure(doc, roadmap_img, "Hình 4: Lộ trình 4 giai đoạn chuyển đổi và tích hợp Cloud cho hệ thống StudyHub", width_inches=6.2)

    add_heading_2(doc, "Kết luận")
    add_body_paragraph(doc,
        "Phương án tích hợp Điện toán đám mây cho hệ thống StudyHub là giải pháp tối ưu và mang tính khả thi cao. Việc kết hợp hài hòa giữa triết lý Local-First (tốc độ cao, sử dụng ngoại tuyến) và sức mạnh của Public Cloud (lưu trữ vô hạn, độ bền 11 số 9, mạng phân phối nội dung CDN) đã giải quyết triệt để mọi rào cản của hạ tầng truyền thống. Đề án này cung cấp cơ sở kỹ thuật vững chắc để phát triển StudyHub thành một nền tảng học tập thông minh, hiện đại và sẵn sàng phục vụ quy mô hàng chục ngàn sinh viên.")

    out_docx_path = os.path.join(DOCS_DIR, "PHUONG_AN_TICH_HOP_CLOUD_STUDYHUB.docx")
    try:
        doc.save(out_docx_path)
        print(f"Đã lưu thành công file Word tại: {out_docx_path}")
        return out_docx_path
    except PermissionError:
        alt_path = os.path.join(DOCS_DIR, "PHUONG_AN_TICH_HOP_CLOUD_STUDYHUB_CAP_NHAT.docx")
        doc.save(alt_path)
        print(f"File Word đang mở, đã lưu tại bản phụ: {alt_path}")
        return alt_path

if __name__ == '__main__':
    build_full_cloud_word_document()
