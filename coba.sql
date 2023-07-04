USE dqlab1;

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