-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1:3306
-- Üretim Zamanı: 26 Ara 2023, 10:38:32
-- Sunucu sürümü: 8.0.31
-- PHP Sürümü: 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `akıllı_seyahat_günlügü`
--

DELIMITER $$
--
-- Yordamlar
--
DROP PROCEDURE IF EXISTS `azalan_sira_para_miktari`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `azalan_sira_para_miktari` ()   SELECT kullanicilar.kullanici_adi, seyahatler.seyahat_adi, sum(seyahatler.toplam_harcama) AS en_yuksek_harcama
FROM kullanicilar,seyahatler,kullanici_seyahat
where kullanicilar.kullanici_id = kullanici_seyahat.kullanici_id
and kullanici_seyahat.seyahat_id = seyahatler.seyahat_id
GROUP BY kullanicilar.kullanici_adi
ORDER BY en_yuksek_harcama DESC$$

DROP PROCEDURE IF EXISTS `bir_mekanin_aldigi_tum_degerlendirmeler`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `bir_mekanin_aldigi_tum_degerlendirmeler` (IN `mekid` INT)   select mekanlar.mekan_id,mekanlar.mekan_adi,degerlendirmeler.degerlendirme_metni,
degerlendirmeler.puan,degerlendirmeler.tarih
from mekanlar,degerlendirmeler
where degerlendirmeler.mekan_id=mekanlar.mekan_id
and mekanlar.mekan_id=mekid$$

DROP PROCEDURE IF EXISTS `hangi_kullanici_hangi_harcama_yaptigi_aktiviteler`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hangi_kullanici_hangi_harcama_yaptigi_aktiviteler` (IN `id` INT)  NO SQL SELECT aktiviteler.aktivite_id, aktiviteler.aktivite_adi, aktiviteler.aktivite_tarihi, aktiviteler.sure, aktiviteler.harcama, aktiviteler.notlar, seyahatler.seyahat_adi, seyahatler.baslangic_tarihi, seyahatler.bitis_tarihi, seyahatler.toplam_harcama
FROM aktiviteler,seyahatler
where aktiviteler.seyahat_id=seyahatler.seyahat_id
and seyahatler.kullanici_id = id$$

DROP PROCEDURE IF EXISTS `hangi_para_kim_harcadi`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hangi_para_kim_harcadi` (IN `para` DECIMAL)   SELECT kullanicilar.kullanici_adi, seyahatler.seyahat_adi, seyahatler.toplam_harcama
FROM kullanicilar,seyahatler,kullanici_seyahat
where kullanicilar.kullanici_id = kullanici_seyahat.kullanici_id
and kullanici_seyahat.seyahat_id = seyahatler.seyahat_id
and seyahatler.toplam_harcama = para$$

DROP PROCEDURE IF EXISTS `kullancinin_mekan_degerlendirme`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `kullancinin_mekan_degerlendirme` (IN `kullanici_id_param` INT(255))   SELECT degerlendirmeler.*
    FROM degerlendirmeler
    WHERE degerlendirmeler.kullanici_id = kullanici_id_param
    AND degerlendirmeler.mekan_id IS NOT NULL$$

DROP PROCEDURE IF EXISTS `kullanici_seyahat_bilgisi`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `kullanici_seyahat_bilgisi` (IN `isim` VARCHAR(255))   select kullanicilar.kullanici_adi,seyahatler.seyahat_adi,seyahatler.baslangic_tarihi,seyahatler.bitis_tarihi,seyahatler.toplam_harcama
from kullanicilar,seyahatler,kullanici_seyahat
where kullanici_seyahat.kullanici_id=kullanicilar.kullanici_id
and kullanici_seyahat.seyahat_id=seyahatler.seyahat_id
and kullanicilar.kullanici_adi=isim$$

DROP PROCEDURE IF EXISTS `mail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `mail` (IN `mail_tur` VARCHAR(255))  NO SQL SELECT kullanicilar.kullanici_adi,kullanicilar.email,seyahatler.seyahat_id,seyahatler.seyahat_adi
FROM  kullanicilar,seyahatler
where kullanicilar.kullanici_id=seyahatler.kullanici_id
and kullanicilar.email LIKE CONCAT('%',mail_tur,'%')$$

DROP PROCEDURE IF EXISTS `mekan_tarihi_araligi`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `mekan_tarihi_araligi` (IN `y1` DATE, IN `y2` DATE)  NO SQL SELECT mekanlar.mekan_id,mekanlar.seyahat_id,mekanlar.mekan_adi,mekanlar.ziyaret_tarihi,mekanlar.notlar
FROM
mekanlar,seyahatler
WHERE 
mekanlar.seyahat_id=seyahatler.seyahat_id
AND mekanlar.ziyaret_tarihi BETWEEN y1 AND y2
ORDER BY mekanlar.ziyaret_tarihi$$

DROP PROCEDURE IF EXISTS `tarih_araligi_bulma`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `tarih_araligi_bulma` (IN `y1` DATE, IN `y2` DATE)   SELECT 
    aktiviteler.aktivite_id, 
    aktiviteler.aktivite_adi, 
    aktiviteler.aktivite_tarihi, 
    aktiviteler.sure, 
    aktiviteler.harcama, 
    aktiviteler.notlar,
    fotograflar.fotograf_adi,
    fotograflar.fotograf_aciklamasi
FROM 
    aktiviteler,fotograflar
where
    fotograflar.aktivite_id = aktiviteler.aktivite_id
and
    aktiviteler.aktivite_tarihi BETWEEN y1 AND y2$$

DROP PROCEDURE IF EXISTS `toplam_harcama`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `toplam_harcama` ()   SELECT Mekanlar.mekan_id, Mekanlar.mekan_adi, ROUND(AVG(Seyahatler.toplam_harcama), 1) AS ortalama_harcama
FROM Mekanlar, Seyahatler
WHERE Mekanlar.seyahat_id = Seyahatler.seyahat_id
GROUP BY Mekanlar.mekan_id, Mekanlar.mekan_adi$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `aktiviteler`
--

DROP TABLE IF EXISTS `aktiviteler`;
CREATE TABLE IF NOT EXISTS `aktiviteler` (
  `aktivite_id` int NOT NULL AUTO_INCREMENT,
  `seyahat_id` int DEFAULT NULL,
  `aktivite_adi` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  `aktivite_tarihi` date DEFAULT NULL,
  `sure` time DEFAULT NULL,
  `harcama` decimal(10,2) DEFAULT NULL,
  `notlar` text COLLATE utf8mb3_turkish_ci,
  PRIMARY KEY (`aktivite_id`),
  KEY `seyahat_id` (`seyahat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `aktiviteler`
--

INSERT INTO `aktiviteler` (`aktivite_id`, `seyahat_id`, `aktivite_adi`, `aktivite_tarihi`, `sure`, `harcama`, `notlar`) VALUES
(1, 1, 'Dalga Sörfü', '2023-01-03', '02:00:00', '200.00', 'Harika bir deneyim.'),
(2, 2, 'Toplantı', '2023-02-16', '04:00:00', '100.00', 'İş arkadaşlarıyla güzel bir gün geçirdik.'),
(3, 3, 'Kahire Gezisi', '2023-04-07', '05:00:00', '300.00', 'Tarihi yerleri ziyaret ettik.'),
(4, 4, 'Alışveriş', '2023-05-22', '03:30:00', '120.00', 'Çeşitli alışverişler yaptık.'),
(5, 5, 'Gece Klubü Partisi', '2023-07-11', '01:00:00', '250.00', 'Eğlenceli bir gece geçirdik.'),
(6, 6, 'Central Park Yürüyüşü', '2023-08-09', '02:30:00', '80.00', 'Doğayla baş başa bir yürüyüş.'),
(7, 7, 'Roma Keşfi', '2023-09-18', '04:00:00', '180.00', 'Tarihi Roma sokaklarında gezi.'),
(8, 8, 'Üniversite Kampüs Turu', '2023-10-11', '03:00:00', '150.00', 'Üniversite kampüsünü keşfettik.'),
(9, 9, 'Saklı Bahçe Kahvaltısı', '2023-11-08', '02:00:00', '100.00', 'Güzel bir bahçede kahvaltı.'),
(10, 10, 'Kayak Merkezi', '2023-12-03', '05:00:00', '220.00', 'Kayak merkezinde eğlenceli zaman geçirdim.'),
(11, 11, 'Kaleiçi Mekan Gezisi', '2023-12-21', '03:30:00', '120.00', 'Kaleiçi mekanlarını gezdik.');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `degerlendirmeler`
--

DROP TABLE IF EXISTS `degerlendirmeler`;
CREATE TABLE IF NOT EXISTS `degerlendirmeler` (
  `degerlendirme_id` int NOT NULL AUTO_INCREMENT,
  `kullanici_id` int DEFAULT NULL,
  `mekan_id` int DEFAULT NULL,
  `degerlendirme_metni` text COLLATE utf8mb3_turkish_ci,
  `puan` int DEFAULT NULL,
  `tarih` date DEFAULT NULL,
  PRIMARY KEY (`degerlendirme_id`),
  KEY `kullanici_id` (`kullanici_id`),
  KEY `mekan_id` (`mekan_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `degerlendirmeler`
--

INSERT INTO `degerlendirmeler` (`degerlendirme_id`, `kullanici_id`, `mekan_id`, `degerlendirme_metni`, `puan`, `tarih`) VALUES
(3, 3, 4, 'Restoranın yemekleri harikaydı, lezzetli bir akşam geçirdik.', 5, '2023-04-07'),
(4, 4, 3, 'Alışveriş merkezi çok geniş, ihtiyacımız olan her şeyi bulduk.', 4, '2023-05-22'),
(5, 5, 9, 'Gece klübü atmosferi çok eğlenceliydi, geceyi coşkulu geçirdik.', 5, '2023-07-11'),
(6, 6, 8, 'Central Parkta yürüyüş yapmak çok keyifliydi, doğayla iç içe.', 4, '2023-08-09'),
(7, 7, 6, 'Romanın tarihi sokaklarını gezmek unutulmaz bir deneyimdi.', 5, '2023-09-18'),
(8, 8, 10, 'Kampüs çok büyüktü', 4, '2023-10-11'),
(9, 9, 11, 'Saklı Bahçe Restoranın kahvaltısı çok lezzetliydi, tekrar gitmeyi düşünüyorum.', 5, '2023-11-08'),
(10, 10, 7, 'Kayak merkezi ekipmanları kaliteliydi, güzel bir kayak deneyimi yaşadık.', 4, '2023-12-03'),
(11, 11, 5, 'Kaleiçi mekanların atmosferi çok özel, herkesin görmesini tavsiye ederim.', 5, '2023-12-21');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `eklenen_kullanici_sayisi`
--

DROP TABLE IF EXISTS `eklenen_kullanici_sayisi`;
CREATE TABLE IF NOT EXISTS `eklenen_kullanici_sayisi` (
  `kullanici_id` int DEFAULT NULL,
  `tarih` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `eklenen_kullanici_sayisi`
--

INSERT INTO `eklenen_kullanici_sayisi` (`kullanici_id`, `tarih`) VALUES
(13, '2023-12-17 17:28:05'),
(14, '2023-12-18 15:16:41'),
(15, '2023-12-18 17:48:32'),
(12, '2023-12-20 18:07:40');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `fotograflar`
--

DROP TABLE IF EXISTS `fotograflar`;
CREATE TABLE IF NOT EXISTS `fotograflar` (
  `fotograf_id` int NOT NULL AUTO_INCREMENT,
  `seyahat_id` int DEFAULT NULL,
  `mekan_id` int DEFAULT NULL,
  `fotograf_adi` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  `fotograf_aciklamasi` text COLLATE utf8mb3_turkish_ci,
  `dosya_yolu` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  `aktivite_id` int DEFAULT NULL,
  PRIMARY KEY (`fotograf_id`),
  KEY `seyahat_id` (`seyahat_id`),
  KEY `mekan_id` (`mekan_id`),
  KEY `fk_foto` (`aktivite_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `fotograflar`
--

INSERT INTO `fotograflar` (`fotograf_id`, `seyahat_id`, `mekan_id`, `fotograf_adi`, `fotograf_aciklamasi`, `dosya_yolu`, `aktivite_id`) VALUES
(1, 1, 1, 'Plaj Günü', 'Denizde çok fazla balık vardı.', '/dosya_yolu/plaj_gunu.jpg', 1),
(2, 2, 2, 'İş Yeri Toplantı', 'Toplantı ortamı Adem Holding ofisinde.', '/dosya_yolu/is_yeri_toplantisi.jpg', NULL),
(3, 3, 3, 'Kahire Akşamı', 'Güzel bir akşam yemeği.', '/dosya_yolu/kahire_aksami.jpg', NULL),
(4, 4, 4, 'Alışveriş Merkezi', 'Alışveriş yapma açısından çeşitlilik.', '/dosya_yolu/alisveris_merkezi.jpg', NULL),
(5, 5, 5, 'Gece Klubü Eğlencesi', 'Eğlenceli bir gece geçirdim.', '/dosya_yolu/gece_klubu_eglencesi.jpg', NULL),
(6, 6, 6, 'Central Park Günü', 'Central Parkın güzellikleri.', '/dosya_yolu/central_park_gunu.jpg', 4),
(7, 7, 7, 'Roma Sokakları', 'Romanın tarihi sokakları.', '/dosya_yolu/roma_sokaklari.jpg', NULL),
(8, 8, 8, 'İstanbul Teknik Üniversitesi', 'İstanbul Teknik Üniversitesi kampüsü.', '/dosya_yolu/itu_kampusu.jpg', NULL),
(9, 9, 9, 'Saklı Bahçe Kahvaltısı', 'Saklı Bahçe Restoranın güzel atmosferi.', '/dosya_yolu/sakli_bahce_kahvalti.jpg', NULL),
(10, 10, 10, 'Kayak Zamanı', 'Kayak Merkezinde eğlenceli zaman geçirdim.', '/dosya_yolu/kayak_zamani.jpg', NULL),
(11, 11, 11, 'Kaleiçi Mekan', 'Kaleiçi mekan eğlencesi.', '/dosya_yolu/kaleiçi_ic_mekan.jpg', NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kategoriler`
--

DROP TABLE IF EXISTS `kategoriler`;
CREATE TABLE IF NOT EXISTS `kategoriler` (
  `kategori_id` int NOT NULL AUTO_INCREMENT,
  `kategori_adi` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  PRIMARY KEY (`kategori_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `kategoriler`
--

INSERT INTO `kategoriler` (`kategori_id`, `kategori_adi`) VALUES
(1, 'Kumsal'),
(2, 'Ofis'),
(3, 'Şehir Turizmi'),
(4, 'Alışveriş'),
(5, 'Eğlence ve Gece Hayatı'),
(6, 'Park ve Bahçe Gezileri'),
(7, 'Tarihi Yerler Keşfi'),
(8, 'Üniversite ve Eğitim'),
(9, 'Restoran ve Kafe Ziyaretleri'),
(10, 'Spor'),
(11, 'Tarihi Yerler');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kategori_aktivite`
--

DROP TABLE IF EXISTS `kategori_aktivite`;
CREATE TABLE IF NOT EXISTS `kategori_aktivite` (
  `kategori_id` int DEFAULT NULL,
  `aktivite_id` int DEFAULT NULL,
  KEY `kategori_id` (`kategori_id`),
  KEY `aktivite_id` (`aktivite_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `kategori_aktivite`
--

INSERT INTO `kategori_aktivite` (`kategori_id`, `aktivite_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kullanicilar`
--

DROP TABLE IF EXISTS `kullanicilar`;
CREATE TABLE IF NOT EXISTS `kullanicilar` (
  `kullanici_id` int NOT NULL AUTO_INCREMENT,
  `kullanici_adi` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  `sifre` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  PRIMARY KEY (`kullanici_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `kullanicilar`
--

INSERT INTO `kullanicilar` (`kullanici_id`, `kullanici_adi`, `email`, `sifre`) VALUES
(1, 'yasingamer', 'ysngamers@email.com', 'Ysn12345'),
(2, 'arteks', 'deneme@gmail.com', 'Arteksem35'),
(3, 'gezgin35', 'gezgin35@email.com', 'gez124568'),
(4, 'kullanicigezgin', 'kullanicigezgin@email.com', 'kullan545gez'),
(5, 'gezerimben', 'gezerimben@email.com', 'gezerimben355'),
(6, 'gezdikgorduk', 'gezdikgorduk@email.com', 'gezdikgorduk5489'),
(7, 'yasınemre', 'yasınemre@email.com', 'yasınemre45687'),
(8, 'senturk1', 'senturk1@email.com', 'senturk23yL5'),
(9, 'turklergeziyor', 'turklergeziyor@email.com', 'TUrkler3589'),
(10, 'japonturk', 'japonturk@email.com', 'japonturK90'),
(11, 'abdliahmet', 'abdahmet3@email.com', 'unitedsts45');

--
-- Tetikleyiciler `kullanicilar`
--
DROP TRIGGER IF EXISTS `eklenen_kullanicilar`;
DELIMITER $$
CREATE TRIGGER `eklenen_kullanicilar` AFTER INSERT ON `kullanicilar` FOR EACH ROW INSERT INTO eklenen_kullanici_sayisi VALUES(
    (SELECT COUNT(kullanicilar.kullanici_id) FROM
 kullanicilar),now())
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `kullanici_guncelleme`;
DELIMITER $$
CREATE TRIGGER `kullanici_guncelleme` AFTER UPDATE ON `kullanicilar` FOR EACH ROW INSERT INTO kullanici_guncelleme(kullanici_id, kullanici_adi, sifre, email)
    VALUES (NEW.kullanici_id, NEW.kullanici_adi, NEW.sifre, NEW.email)
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `silinen_kullanicilar`;
DELIMITER $$
CREATE TRIGGER `silinen_kullanicilar` AFTER DELETE ON `kullanicilar` FOR EACH ROW INSERT INTO silinen_kullanicilar (kullanici_id, silinme_tarihi)
    VALUES (OLD.kullanici_id, CURRENT_TIMESTAMP)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kullanici_guncelleme`
--

DROP TABLE IF EXISTS `kullanici_guncelleme`;
CREATE TABLE IF NOT EXISTS `kullanici_guncelleme` (
  `kullanici_id` int DEFAULT NULL,
  `kullanici_adi` varchar(255) COLLATE utf8mb3_turkish_ci DEFAULT NULL,
  `sifre` varchar(255) COLLATE utf8mb3_turkish_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb3_turkish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `kullanici_guncelleme`
--

INSERT INTO `kullanici_guncelleme` (`kullanici_id`, `kullanici_adi`, `sifre`, `email`) VALUES
(2, 'arteks', 'Arteksem35', 'deneme@gmail.com');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kullanici_seyahat`
--

DROP TABLE IF EXISTS `kullanici_seyahat`;
CREATE TABLE IF NOT EXISTS `kullanici_seyahat` (
  `kullanici_id` int NOT NULL,
  `seyahat_id` int NOT NULL,
  PRIMARY KEY (`kullanici_id`,`seyahat_id`),
  KEY `seyahat_id` (`seyahat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `kullanici_seyahat`
--

INSERT INTO `kullanici_seyahat` (`kullanici_id`, `seyahat_id`) VALUES
(1, 1),
(2, 2),
(4, 3),
(3, 4),
(9, 5),
(8, 6),
(6, 7),
(10, 8),
(11, 9),
(7, 10),
(5, 11);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `mekanlar`
--

DROP TABLE IF EXISTS `mekanlar`;
CREATE TABLE IF NOT EXISTS `mekanlar` (
  `mekan_id` int NOT NULL AUTO_INCREMENT,
  `seyahat_id` int DEFAULT NULL,
  `mekan_adi` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  `ziyaret_tarihi` date DEFAULT NULL,
  `notlar` text COLLATE utf8mb3_turkish_ci,
  PRIMARY KEY (`mekan_id`),
  KEY `seyahat_id` (`seyahat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `mekanlar`
--

INSERT INTO `mekanlar` (`mekan_id`, `seyahat_id`, `mekan_adi`, `ziyaret_tarihi`, `notlar`) VALUES
(1, 1, 'Plaj', '2023-01-03', 'Deniz ve kum keyfi.'),
(2, 2, 'Yasin Holding ', '2023-02-16', 'Salon ve toplantı sandalyeleri çok güzeldi ortak alanlarda  toplantı yapmak isteyen herkese tavsiye ederim.'),
(3, 4, 'Kahire', '2023-04-07', 'Güzel bir akşam yemeği.'),
(4, 3, 'Alışveriş Merkezi', '2023-05-22', 'Alışveriş yapma açışından çeşitlilik çok fazlaydı.'),
(5, 9, 'Gece Klubü', '2023-07-11', 'Eğlenceli bir gece geçirdim.'),
(6, 8, 'Centrak Park', '2023-08-09', 'Açık havası ve parkı çok güzeldi ve temizdi.'),
(7, 6, 'Roma', '2023-09-18', 'Tarihi yapısı,kokusu beni benden aldı.'),
(8, 10, 'İstanbul Teknik Üniversitesi Kampüsü', '2023-10-11', 'Konaklama yapılan otel.'),
(9, 11, 'Saklı Bahçe Restorant', '2023-11-08', 'Günlük ağaçları ve kahvaltı çok güzeldi.Arılar bizi kovaladı çok fazla arı var'),
(10, 7, 'Kayak Merkezi', '2023-12-03', 'Kayaklar çok kaliteliydi.'),
(11, 5, 'Kaleiçi', '2023-12-21', 'İçindeki dükkanlar çok tatlı ama biraz cep yakandı.');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `seyahatler`
--

DROP TABLE IF EXISTS `seyahatler`;
CREATE TABLE IF NOT EXISTS `seyahatler` (
  `seyahat_id` int NOT NULL AUTO_INCREMENT,
  `kullanici_id` int DEFAULT NULL,
  `seyahat_adi` varchar(255) COLLATE utf8mb3_turkish_ci NOT NULL,
  `baslangic_tarihi` date DEFAULT NULL,
  `bitis_tarihi` date DEFAULT NULL,
  `toplam_harcama` decimal(10,2) DEFAULT NULL,
  `notlar` text COLLATE utf8mb3_turkish_ci,
  PRIMARY KEY (`seyahat_id`),
  KEY `kullanici_id` (`kullanici_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `seyahatler`
--

INSERT INTO `seyahatler` (`seyahat_id`, `kullanici_id`, `seyahat_adi`, `baslangic_tarihi`, `bitis_tarihi`, `toplam_harcama`, `notlar`) VALUES
(1, 1, 'Bodrum', '2023-01-01', '2023-01-10', '1500.00', 'Harika bir tatil geçirdim.'),
(2, 2, 'İş Seyahati', '2023-02-15', '2023-02-20', '1200.00', 'İş görüşmeleri ve toplantılar.'),
(3, 4, 'Mısır', '2023-04-05', '2023-04-15', '9000.00', 'Şehir turu yaptım.'),
(4, 3, 'Didim', '2023-05-20', '2023-05-25', '9000.00', 'Deniz kenarında dinlendiğim bir tatil.'),
(5, 9, 'Ankara', '2023-07-10', '2023-07-15', '1900.00', 'İş toplantıları ve müşteri ziyaretleri.'),
(6, 8, 'New York', '2023-08-01', '2023-08-10', '1200.00', 'Tarihi yerleri gezdim.'),
(7, 6, 'İtalya', '2023-09-15', '2023-09-22', '1600.00', 'Şehir olarak tarihi yapıları gezdim ve ünlü yemeklerinden pizzayı yedim tadı süperdi.'),
(8, 10, 'İstanbul', '2023-10-10', '2023-10-15', '1100.00', 'Eğitim için kaliteli bir şehir toplu taşımada bir numara çok beğendim'),
(9, 11, 'Marmaris', '2023-11-05', '2023-11-12', '1400.00', 'Doğa ile iç içe bir tatil.'),
(10, 7, 'Uludağ', '2023-12-01', '2023-12-10', '20000.00', 'Dağ evinde konakladığım  ve kayak yaptığım bir tatildi.'),
(11, 5, 'Antalya', '2023-12-20', '2023-12-25', '80000.00', 'Şehir turu yaptım özellikle kaleiçini çok beğendim , denizi ve tekne turları çok güzeldi'),
(12, 1, 'Orman', '2023-12-20', '2023-12-25', '1200.00', 'Doğa ile baş başa kalma fırsatı.'),
(13, 1, 'Araba Müzesi', '2023-12-20', '2023-12-25', '15000.00', 'Klasik arabalar gördüm hepsi harikaydı.'),
(14, 1, 'Araba Müzesi', '2023-12-25', '2023-12-30', '1000.00', 'Tekrar gittim çünkü o atmosfer çok güzeldi.');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `silinen_kullanicilar`
--

DROP TABLE IF EXISTS `silinen_kullanicilar`;
CREATE TABLE IF NOT EXISTS `silinen_kullanicilar` (
  `silinme_id` int NOT NULL AUTO_INCREMENT,
  `kullanici_id` int DEFAULT NULL,
  `silinme_tarihi` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`silinme_id`),
  KEY `kullanici_id` (`kullanici_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `silinen_kullanicilar`
--

INSERT INTO `silinen_kullanicilar` (`silinme_id`, `kullanici_id`, `silinme_tarihi`) VALUES
(1, 12, '2023-12-18 15:43:13'),
(2, 19, '2023-12-20 15:08:02');

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `aktiviteler`
--
ALTER TABLE `aktiviteler`
  ADD CONSTRAINT `aktiviteler_ibfk_1` FOREIGN KEY (`seyahat_id`) REFERENCES `seyahatler` (`seyahat_id`);

--
-- Tablo kısıtlamaları `degerlendirmeler`
--
ALTER TABLE `degerlendirmeler`
  ADD CONSTRAINT `degerlendirmeler_ibfk_1` FOREIGN KEY (`kullanici_id`) REFERENCES `kullanicilar` (`kullanici_id`),
  ADD CONSTRAINT `degerlendirmeler_ibfk_2` FOREIGN KEY (`mekan_id`) REFERENCES `mekanlar` (`mekan_id`);

--
-- Tablo kısıtlamaları `fotograflar`
--
ALTER TABLE `fotograflar`
  ADD CONSTRAINT `fk_foto` FOREIGN KEY (`aktivite_id`) REFERENCES `aktiviteler` (`aktivite_id`),
  ADD CONSTRAINT `fotograflar_ibfk_1` FOREIGN KEY (`seyahat_id`) REFERENCES `seyahatler` (`seyahat_id`),
  ADD CONSTRAINT `fotograflar_ibfk_2` FOREIGN KEY (`mekan_id`) REFERENCES `mekanlar` (`mekan_id`);

--
-- Tablo kısıtlamaları `kategori_aktivite`
--
ALTER TABLE `kategori_aktivite`
  ADD CONSTRAINT `kategori_aktivite_ibfk_1` FOREIGN KEY (`kategori_id`) REFERENCES `kategoriler` (`kategori_id`),
  ADD CONSTRAINT `kategori_aktivite_ibfk_2` FOREIGN KEY (`aktivite_id`) REFERENCES `aktiviteler` (`aktivite_id`);

--
-- Tablo kısıtlamaları `kullanici_seyahat`
--
ALTER TABLE `kullanici_seyahat`
  ADD CONSTRAINT `kullanici_seyahat_ibfk_1` FOREIGN KEY (`kullanici_id`) REFERENCES `kullanicilar` (`kullanici_id`),
  ADD CONSTRAINT `kullanici_seyahat_ibfk_2` FOREIGN KEY (`seyahat_id`) REFERENCES `seyahatler` (`seyahat_id`);

--
-- Tablo kısıtlamaları `mekanlar`
--
ALTER TABLE `mekanlar`
  ADD CONSTRAINT `mekanlar_ibfk_1` FOREIGN KEY (`seyahat_id`) REFERENCES `seyahatler` (`seyahat_id`);

--
-- Tablo kısıtlamaları `seyahatler`
--
ALTER TABLE `seyahatler`
  ADD CONSTRAINT `seyahatler_ibfk_1` FOREIGN KEY (`kullanici_id`) REFERENCES `kullanicilar` (`kullanici_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
