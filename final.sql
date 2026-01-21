create database finalExam;

use finalExam;

create table Readers(
	reader_id int auto_increment primary key,
    full_name varchar(255) not null,
    email varchar(255) unique not null,
    phone_number varchar(10) not null,
    created_at date default(current_date())
);

create table Membership_Details(
	card_number varchar(8) primary key,
    reader_id int unique not null,
    rank_card enum('Standard', 'VIP') not null,
    expiry_date date not null,
    citizen_id int unique not null,
    foreign key (reader_id) references Readers(reader_id)
);

create table Categories(
	category_id int auto_increment primary key,
    category_name varchar(255) not null,
    description text
);

create table Books(
	book_id int auto_increment primary key,
    title varchar(255) not null,
    author varchar(255) not null,
    category_id int not null,
    price decimal(10,2) check(price > 0),
    stock_quantity int check(stock_quantity >=0),
    foreign key (category_id) references Categories(category_id)
);

create table Loan_Records(
	loan_id int primary key,
    reader_id int not null,
    book_id int not null,
    borrow_date date not null,
    due_date date not null,
    return_date date,
    foreign key (reader_id) references Readers(reader_id),
    foreign key (book_id) references Books(book_id)
);



--  Viết Script chèn dữ liệu:

insert into Readers(full_name, email, phone_number, created_at)
value
	('Nguyen Van A', 'anv@gmail.com', '901234567' , '2022-01-15'),
	('Tran Thi B', 'btt@gmail.com', '912345678', '2022-05-22'),
    ('Le Van C', 'cle@yahoo.com', '922334455', '2023-02-10'),
    ('Pham Minh D', 'dpham@hotmail.com', '933445566', '2023-11-05'),
    ('Hoang Anh E', 'ehoang@gmail.com', '944556677', '2024-01-12');

insert into Membership_Details(card_number, reader_id, rank_card, expiry_date, citizen_id)
value
	('CARD-001', 1, 'Standard', '2025-01-15', '123456789'),
    ('CARD-002', 2, 'Vip', '2025-05-20', '234567890'),
    ('CARD-003', 3, 'Standard', '2024-02-10', '345678901'),
    ('CARD-004', 4, 'Vip', '2025-11-05', '456789012'),
    ('CARD-005', 5, 'Standard', '2026-01-12', '567890123');

insert into Categories(category_name, description)
value
	('IT', 'Sách về công nghệ thông tin và lập trình'),
    ('Kinh Te', 'Sách kinh doanh, tài chính, khởi nghiệp'),
    ('Van Hoc', 'Tiểu thuyết, truyện ngắn, thơ'),
    ('Ngoai Ngu', 'Sách học tiếng Anh, Nhật, Hàn'),
    ('Lich Su', 'Sách nghiên cứu lịch sử, văn hóa');

insert into Books( title, author, category_id, price, stock_quantity)
value
	('Clean Code', 'Robert C. Martin', 1, '450000', 10),
    ('Dac Nhan Tam', 'Dale Carnegie', 2, '150000', 50),
    ('Harry Potter 1', 'J.K. Rowling', 3, '250000', 5),
    ('IELTS Reading', 'Cambridge', 4, '180000', 0),
    ('Dai Viet Su Ky', 'Le Van Huu', 5, '300000', 20);

insert into Loan_Records(loan_id, reader_id, book_id, borrow_date, due_date, return_date)
value
	(101 , 1 , 1 , '2023-11-15' , '2023-11-22' , '2023-11-20'),
    (102 , 2 , 2 , '2023-12-01' , '2023-12-08' , '2023-12-05'),
    (103 , 1 , 3 , '2024-01-10' , '2024-01-17', null ),
    (104 , 3 , 4 , '2023-05-20' , '2023-05-27', null ),
    (105 , 4 , 1 , '2024-01-18' , '2023-01-25', null );


-- - Gia hạn thêm 7 ngày cho due_date (Ngày dự kiến trả) đối với tất cả các phiếu mượn sách thuộc danh mục 'Van Hoc' mà chưa được trả (return_date IS NULL).
update Loan_Records
set due_date = DATE_ADD(due_date, interval 7 day)
where return_date is null
and book_id in (select book_id from Books b join Categories c ON b.category_id = c.category_id where c.category_name = 'Van Hoc');

--   - Xóa các hồ sơ mượn trả (Loan_Records) đã hoàn tất trả sách (return_date KHÔNG NULL) và có ngày mượn trước tháng 10/2023.

delete from Loan_Records
where return_date is not null
and borrow_date < '2023-10-01';



-- PHẦN 2: TRUY VẤN DỮ LIỆU CƠ BẢN (15 ĐIỂM)

-- - Câu 1 (5đ): Viết câu lệnh lấy ra danh sách các cuốn sách (book_id, title, price) thuộc danh mục 'IT' và có giá bán lớn hơn 200.000 VNĐ.

select book_id, title, price
from Books
where category_id in (select category_id from Categories where category_name = 'IT')
and price > 200000;

-- - Câu 2 (5đ): Lấy ra thông tin độc giả (reader_id, full_name, email) đã đăng ký tài khoản trong năm 2022 và có địa chỉ Email thuộc tên miền '@gmail.com'.

select reader_id, full_name, email
from Readers
where year(created_at) = 2022
and email like '%@gmail.com';

-- - Câu 3 (5đ): Hiển thị danh sách 5 cuốn sách có giá trị cao nhất, sắp xếp theo thứ tự giảm dần. Yêu cầu sử dụng LIMIT và OFFSET để bỏ qua 2 cuốn sách đắt nhất đầu tiên (lấy từ cuốn thứ 3 đến thứ 7).

select *
from books
order by price desc
limit 5 offset 2;



-- PHẦN 3: TRUY VẤN DỮ LIỆU NÂNG CAO (20 ĐIỂM)

-- - Câu 1 (6đ): Viết truy vấn để hiển thị các thông tin gômg: Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, Ngày trả. Chỉ hiển thị các đơn mượn chưa trả sách.

select LR.loan_id, R.full_name, B.title, LR.borrow_date, LR.due_date
from Loan_Records LR
join Readers R on LR.reader_id = R.reader_id
join Books B on LR.book_id = B.book_id
where LR.return_date is null;

-- - Câu 2 (7đ): Tính tổng số lượng sách đang tồn kho (stock_quantity) của từng danh mục (category_name). Chỉ hiển thị những danh mục có tổng tồn kho lớn hơn 10.

select C.category_name, sum(stock_quantity) AS total_stock
from Books B
left join Categories C on B.category_id = C.category_id
group by C.category_name
having total_stock > 10;

-- - Câu 3 (7đ): Tìm ra thông tin độc giả (full_name) có hạng thẻ là 'VIP' nhưng chưa từng mượn cuốn sách nào có giá trị lớn hơn 300.000 VNĐ.

select R.full_name , B.price
from Loan_Records LR
join Readers R on LR.reader_id = R.reader_id
join Books B on LR.book_id = B.book_id
where B.price > 300000 and R.full_name in (select R.full_name
from Readers R
join Membership_Details MD on  R.reader_id = MD.reader_id
where MD.rank_card = 'Vip');



-- PHẦN 4: INDEX VÀ VIEW (10 ĐIỂM)

-- - Câu 1 (5đ): Tạo một Composite Index đặt tên là idx_loan_dates trên bảng Loan_Records bao gồm hai cột: borrow_date và return_date để tăng tốc độ truy vấn lịch sử mượn.

create index idx_loan_dates on Loan_Records(borrow_date,return_date);

-- - Câu 2 (5đ): Tạo một View tên là vw_overdue_loans hiển thị: Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, Ngày dự kiến trả. View này chỉ chứa các bản ghi mà ngày hiện tại (CURDATE) đã vượt quá ngày dự kiến trả và sách chưa được trả.--

create view vw_overdue_loans
as
	select LR.loan_id, R.full_name, B.title, LR.borrow_date, LR.due_date
	from Loan_Records LR
	join Readers R on LR.reader_id = R.reader_id
	join Books B on LR.book_id = B.book_id
	where LR.return_date is null;



-- PHẦN 5: TRIGGER (10 ĐIỂM)

-- - Câu 1 (5đ): Viết Trigger trg_after_loan_insert. Khi một phiếu mượn mới được thêm vào bảng Loan_Records, hãy tự động trừ số lượng tồn kho (stock_quantity) của cuốn sách tương ứng trong bảng Books đi 1 đơn vị.

DELIMITER //
create trigger trg_after_loan_insert
after insert on Loan_Records
for each row
begin
    update Books
    set stock_quantity = stock_quantity - 1
    where book_id = NEW.book_id;
end //
DELIMITER ;

-- - Câu 2 (5đ): Viết Trigger trg_prevent_delete_active_reader. Ngăn chặn việc xóa thông tin độc giả trong bảng Readers nếu độc giả đó vẫn còn sách đang mượn (tức là tồn tại bản ghi trong Loan_Records mà return_date là NULL). Gợi ý: Sử dụng SIGNAL SQLSTATE.
DELIMITER //
create trigger trg_prevent_delete_active_reader
before delete on Readers
for each row
begin
    if exists (select 1 from Loan_Records where reader_id = old.reader_id and return_date is null) then
        signal sqlstate '45000'
        set MESSAGE_TEXT = 'Khong the xoa: Doc gia nay van con sach chua tra.';
    end if;
end //
DELIMITER ;



-- PHẦN 6: STORED PROCEDURE (20 ĐIỂM)

-- Câu 1 (10đ): Viết Procedure sp_check_availability nhận vào Mã sách (p_book_id). Procedure trả về thông báo qua tham số OUT p_message:
-- 'Hết hàng' nếu tồn kho = 0.
-- 'Sắp hết' nếu 0 < tồn kho <= 5.
-- 'Còn hàng' nếu tồn kho > 5.

DELIMITER //
create procedure sp_check_availability(
    in p_book_id int,
    out p_message varchar(50)
)
begin
    declare v_stock int;
    select stock_quantity into v_stock from Books where book_id = p_book_id;

    if v_stock = 0 then set p_message = 'Hết hàng';
    elseif v_stock <= 5 then set p_message = 'Sắp hết';
    else set p_message = 'Còn hàng';
    end if;
end //
DELIMITER ;

-- Câu 2 (10đ): Viết Procedure sp_return_book_transaction để xử lý trả sách an toàn với Transaction:
-- Input: p_loan_id.
-- B1: Bắt đầu giao dịch (START TRANSACTION).
-- B2: Kiểm tra xem phiếu mượn này đã được trả chưa. Nếu return_date không NULL, Rollback và báo lỗi "Sách đã trả rồi".
-- B3: Cập nhật ngày trả (return_date) là ngày hiện tại trong bảng Loan_Records.
-- B4: Cộng lại số lượng tồn kho (stock_quantity) lên 1 trong bảng Books (dựa vào book_id lấy từ phiếu mượn).
-- B5: COMMIT nếu thành công. ROLLBACK nếu có lỗi xảy ra.

DELIMITER //
create procedure sp_return_book_transaction(in p_loan_id int)
begin
    declare v_book_id int;
    declare v_returned date;

    declare EXIT HANDLER for SQLEXCEPTION
    begin
        rollback ;
    end;

    start transaction ;

    select book_id, return_date into v_book_id, v_returned from Loan_Records where loan_id = p_loan_id;

    if v_returned is not null then
        signal sqlstate '45000' set MESSAGE_TEXT = 'Sách đã trả rồi';
    else
        update Loan_Records set return_date = CURDATE() where loan_id = p_loan_id;
        update Books set stock_quantity = stock_quantity + 1 where book_id = v_book_id;
        commit ;
    end if;
end //
DELIMITER ;
