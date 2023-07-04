USE dqlab1;

-- Jumlah Transaksi Per Bulan
SELECT
 DATE_FORMAT(created_at, '%Y-%m') AS Bulan,
 count(1) AS jumlah_transaksi
FROM
 orders
GROUP BY
 1
ORDER BY
 1;

-- Status Transaksi 
-- Jumlah transaksi yang tidak dibayar
SELECT count(1) AS transaksi_tidak_dibayar FROM orders WHERE paid_at = 'NA';
-- Jumlah transaksi yang sudah dibayar tapi tidak dikirim
SELECT count(1) AS transaksi_dibayar_tidak_dikirim FROM orders WHERE paid_at != 'NA' AND delivery_at = 'NA';
-- Jumlah transaksi yang tidak dikirim, baik yang sudah dibayar maupun belum
SELECT count(1) AS transaksi_tidak_dikirim FROM orders WHERE delivery_at = 'NA' AND (paid_at != 'NA' OR paid_at = 'NA');
-- Jumlah transaksi yang dikirim pada hari yang sama dengan tanggal dibayar
SELECT count(1) AS jumlah_transaksi FROM orders WHERE paid_at = delivery_at;

-- Pengguna Transaksi
-- Total Seluruh Pengguna
SELECT count(DISTINCT user_id) AS jumlah_seluruh_pengguna FROM users;
-- Total pengguna yang pernah bertransaksi sebagai pembeli
SELECT count(DISTINCT buyer_id) AS jumlah_buyer FROM orders;
-- Total pengguna yang pernah bertransaksi sebagai penjual
SELECT count(DISTINCT seller_id) AS jumlah_seller FROM orders;
-- Total pengguna yang pernah bertransaksi sebagai pembeli dan pernah sebagai penjual
SELECT count(DISTINCT seller_id) AS buyer_and_seller FROM orders WHERE seller_id IN (SELECT buyer_id FROM orders);
-- Total pengguna yang tidak pernah bertransaksi sebagai pembeli maupun penjual
SELECT count(DISTINCT user_id) AS pengguna_tidak_pernah_trx FROM users
WHERE
 user_id
 NOT IN
 (
  SELECT buyer_id FROM orders UNION SELECT seller_id FROM orders
 );

-- Top Buyer all time
-- 5 pembeli dengan dengan total pembelian terbesar (berdasarkan total harga barang setelah diskon)
SELECT
 buyer_id,
 nama_user,
 sum(total) AS total_transaksi
FROM
 orders o
JOIN
 users u
 ON o.buyer_id = u.user_id
GROUP BY
 1,2
ORDER BY
 3 DESC
LIMIT
 5;

-- Frequent Buyer
-- Mendapatkan siapa pembeli yang tidak pernah menggunakan diskon ketika membeli barang dan merupakan 5 pembeli dengan transaksi terbanyak
SELECT
 buyer_id,
 nama_user,
 count(order_id) AS jumlah_transaksi
FROM
 orders o
JOIN
 users u
 ON o.buyer_id = u.user_id
WHERE 
 discount = 0
GROUP BY
 1,2
ORDER BY
 3 DESC, 2
LIMIT
 5;

-- Big Frequent Buyer 2020
-- Dari daftar email pengguna berikut ini, mana saja pengguna yang bertransaksi setidaknya 1 kali setiap bulan di tahun 2020 dengan rata-rata total amount per transaksi lebih dari 1 Juta
SELECT
 buyer_id,
 email,
 rata_rata,
 month_count
FROM
(
 SELECT
  trx.buyer_id,
  rata_rata,
  jumlah_order,
  month_count
 FROM
  (
   SELECT
    buyer_id,
    round(avg(total),2) AS rata_rata
   FROM
    orders
   WHERE     
    DATE_FORMAT(created_at, '%Y') = '2020'
   GROUP BY
    1
   HAVING
    rata_rata > 1000000
   ORDER BY
    1
  ) AS trx
 JOIN
  (
   SELECT
    buyer_id,
    count(order_id) AS jumlah_order,
    count(DISTINCT DATE_FORMAT(created_at, '%m')) AS month_count
   FROM
    orders
   WHERE     
    DATE_FORMAT(created_at, '%Y') = '2020'
   GROUP BY
    1
   HAVING
    month_count >= 5
    AND
    jumlah_order >= month_count
   ORDER BY
    1
  ) AS months
  ON trx.buyer_id = months.buyer_id
) AS bfq
JOIN
 users
 ON buyer_id = user_id;

 -- Domain email dari penjual
-- manakah yang merupakan domain email dari penjual di DQLab Store.
-- *domain adalah nama unik setelah tanda @, biasanya menggambarkan nama organisasi dan imbuhan internet standar (seperti .com, .co.id dan lainnya)
SELECT
 DISTINCT substr(email, instr(email, '@') + 1) AS domain_email,
 count(user_id) AS jumlah_pengguna_seller
FROM
 users
WHERE
 user_id IN
 (
  SELECT seller_id FROM orders
 )
GROUP BY
 1
ORDER BY
 2 DESC;

-- Top 5 Product Desember 2019
-- mencari top 5 produk yang dibeli di bulan desember 2019 berdasarkan total quantity
SELECT
 sum(quantity) AS total_quantity,
 desc_product
FROM
 order_details od
JOIN
 products p
 ON od.product_id = p.product_id
JOIN
 orders o
 ON od.order_id = o.order_id
WHERE
 created_at BETWEEN '2019-12-01' AND '2019-12-31'
GROUP BY
 2
ORDER BY
 1 DESC
LIMIT
 5;