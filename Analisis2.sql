USE dqlab1;

-- Mencari pembeli high value
SELECT
    nama_user AS nama_pembeli,
    COUNT(1) AS jumlah_transaksi,
    SUM(total) AS total_nilai_transaksi,
    MIN(total) AS min_nilai_transaksi
FROM
    orders
    INNER JOIN users ON buyer_id = user_id
GROUP BY
    user_id,
    nama_user
HAVING
    COUNT(1) > 5
    AND MIN(total) > 2000000
ORDER BY
    3 DESC;

-- Mencari Dropshipper
SELECT
    nama_user AS nama_pembeli,
    COUNT(1) AS jumlah_transaksi,
    COUNT(DISTINCT orders.kodepos) AS distinct_kodepos,
    SUM(total) AS total_nilai_transaksi,
    AVG(total) AS avg_nilai_transaksi
FROM
    orders
    INNER JOIN users ON buyer_id = user_id
GROUP BY
    user_id,
    nama_user
HAVING
    COUNT(1) >= 10
    AND COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY
    2 DESC;

-- Mencari Reseller Offline
SELECT
    nama_user AS nama_pembeli,
    COUNT(1) AS jumlah_transaksi,
    SUM(total) AS total_nilai_transaksi,
    AVG(total) AS avg_nilai_transaksi,
    AVG(total_quantity) AS avg_quantity_per_transaksi
FROM
    orders
    INNER join users ON buyer_id = user_id
    INNER JOIN (
        SELECT
            order_id,
            SUM(quantity) AS total_quantity
        FROM
            order_details
        GROUP BY
            1
    ) AS summary_order USING (order_id)
    WHERE
        orders.kodepos = users.kodepos
    GROUP BY
        user_id,
        nama_user
    HAVING
        COUNT(1) >= 8
        AND AVG(total_quantity) > 10
    ORDER BY
        3 DESC;

-- Pembeli sekaligus penjual
SELECT
    nama_user AS nama_pengguna,
    jumlah_transaksi_beli,
    jumlah_transaksi_jual
FROM
    users
    INNER JOIN (
        SELECT
            buyer_id,
            COUNT(1) AS jumlah_transaksi_beli
        FROM
            orders
        GROUP BY
            1
    ) AS buyer ON buyer_id = user_id
    INNER JOIN (
        SELECT
            seller_id,
            COUNT(1) AS jumlah_transaksi_jual
        FROM
            orders
        GROUP BY
            1
    ) AS seller ON seller_id = user_id
WHERE
    jumlah_transaksi_beli >= 7
ORDER BY
    1;

-- Lama transaksi dibayar
SELECT
    EXTRACT(
        YEAR_MONTH
        FROM
            created_at
    ) AS tahun_bulan,
    COUNT(1) AS jumlah_transaksi,
    AVG(DATEDIFF(paid_at, created_at)) AS avg_lama_dibayar,
    MIN(DATEDIFF(paid_at, created_at)) min_lama_dibayar,
    MAX(DATEDIFF(paid_at, created_at)) max_lama_dibayar
FROM
    orders
WHERE
    paid_at IS NOT NULL
GROUP BY
    1
ORDER BY
    1;