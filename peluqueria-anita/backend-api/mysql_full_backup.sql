-- MySQL dump 10.13  Distrib 9.4.0, for macos26.0 (arm64)
--
-- Host: localhost    Database: railway
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointment_details`
--

DROP TABLE IF EXISTS `appointment_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` bigint unsigned NOT NULL,
  `service_id` bigint unsigned NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `appointment_details_appointment_id_foreign` (`appointment_id`),
  KEY `appointment_details_service_id_foreign` (`service_id`),
  CONSTRAINT `appointment_details_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointment_details_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_details`
--

LOCK TABLES `appointment_details` WRITE;
/*!40000 ALTER TABLE `appointment_details` DISABLE KEYS */;
INSERT INTO `appointment_details` VALUES (1,1,1,1,25.00,25.00,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(2,2,2,1,15.00,15.00,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(3,3,2,1,15.00,15.00,'2025-10-04 11:38:38','2025-10-04 11:38:38'),(5,5,7,1,20.00,20.00,'2025-10-05 01:14:25','2025-10-05 01:14:25');
/*!40000 ALTER TABLE `appointment_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `client_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `appointment_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` enum('pending','confirmed','in_progress','completed','cancelled','no_show') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `appointments_appointment_date_index` (`appointment_date`),
  KEY `appointments_client_id_index` (`client_id`),
  KEY `appointments_user_id_index` (`user_id`),
  KEY `appointments_status_index` (`status`),
  CONSTRAINT `appointments_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (1,1,2,'2025-10-05','10:00:00','11:00:00','confirmed',0.00,'Cliente prefiere corte bob','2025-10-04 07:42:54','2025-10-04 07:42:54'),(2,2,3,'2025-10-06','09:30:00','09:30:00','cancelled',0.00,NULL,'2025-10-04 07:42:54','2025-10-05 01:23:39'),(3,4,2,'2025-10-04','09:00:00','09:30:00','pending',15.00,NULL,'2025-10-04 11:38:38','2025-10-04 11:38:38'),(5,1,1,'2025-10-10','14:30:00','11:30:00','pending',20.00,'app movil','2025-10-05 01:14:25','2025-10-05 01:28:53');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attentions`
--

DROP TABLE IF EXISTS `attentions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attentions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` bigint unsigned NOT NULL,
  `client_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `service_id` bigint unsigned NOT NULL,
  `attention_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` enum('started','in_progress','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'started',
  `service_price` decimal(10,2) NOT NULL,
  `observations` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `products_used` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tip_amount` decimal(8,2) NOT NULL DEFAULT '0.00',
  `client_satisfaction` enum('very_unsatisfied','unsatisfied','neutral','satisfied','very_satisfied') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attentions_appointment_id_foreign` (`appointment_id`),
  KEY `attentions_service_id_foreign` (`service_id`),
  KEY `attentions_attention_date_status_index` (`attention_date`,`status`),
  KEY `attentions_client_id_attention_date_index` (`client_id`,`attention_date`),
  KEY `attentions_user_id_attention_date_index` (`user_id`,`attention_date`),
  CONSTRAINT `attentions_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attentions_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attentions_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attentions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attentions`
--

LOCK TABLES `attentions` WRITE;
/*!40000 ALTER TABLE `attentions` DISABLE KEYS */;
INSERT INTO `attentions` VALUES (1,1,1,2,1,'2025-10-02','09:00:00','09:30:00','completed',25.00,'Cliente muy satisfecho con el corte. Cabello graso, recomendado shampoo especial.','Shampoo clarificante, acondicionador hidratante, gel de peinado',5.00,'very_satisfied','Cliente frecuente, próxima cita en 4 semanas','2025-10-04 09:09:54','2025-10-04 09:09:54'),(2,1,2,3,2,'2025-10-05','14:00:00','16:00:00','in_progress',45.00,'Cambio de color dramático, de castaño a rubio. Proceso de decoloración realizado.','Decolorante profesional, tinte rubio ceniza, mascarilla reparadora, protector térmico',8.00,'satisfied','Recomendado tratamiento de hidratación semanal','2025-10-04 09:09:54','2025-10-04 20:22:10'),(3,1,3,2,3,'2025-10-04','11:00:00','12:00:00','in_progress',30.00,'Peinado para evento especial. Estilo elegante con ondas suaves.','Mousse voluminizadora, spray fijador, aceite de brillo',0.00,NULL,'Evento a las 18:00, cliente muy nerviosa','2025-10-04 09:09:54','2025-10-04 09:09:54'),(4,1,1,3,4,'2025-10-01','16:30:00','17:30:00','completed',35.00,'Cabello muy dañado por químicos anteriores. Aplicado tratamiento intensivo.','Mascarilla proteínas, ampolla de keratina, aceite de argán',7.00,'very_satisfied','Programar seguimiento en 2 semanas','2025-10-04 09:09:54','2025-10-04 09:09:54'),(5,2,2,2,1,'2025-09-27','10:15:00','10:45:00','completed',25.00,'Corte bob clásico. Cliente quería cambio de look radical.','Shampoo texturizante, crema de peinado, spray de volumen',3.00,'satisfied','Cliente se adapta bien al nuevo corte','2025-10-04 09:09:54','2025-10-04 09:09:54'),(6,1,4,1,1,'2025-10-04','10:00:00','11:00:00','in_progress',25.00,'aaaa','aaaaa',5.00,NULL,'aaaaa','2025-10-04 20:33:58','2025-10-04 20:33:58');
/*!40000 ALTER TABLE `attentions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `birth_date` date DEFAULT NULL,
  `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clients_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (1,'Laura Martín','laura@email.com','555-1001','Calle Principal 123','1990-05-15','female',NULL,1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(2,'Pedro Sánchez','pedro@email.com','555-1002','Avenida Central 456','1985-08-22','male',NULL,1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(3,'Ana Torres','ana@email.com','555-1003','Plaza Mayor 789','1992-12-10','female',NULL,1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(4,'Cliente de Prueba 1759555986481','test1759555986481@example.com','555-9813','Dirección de Prueba 123',NULL,'other',NULL,1,'2025-10-04 10:33:08','2025-10-04 10:33:08');
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2025_10_04_000926_create_clients_table',1),(5,'2025_10_04_000942_create_services_table',1),(6,'2025_10_04_000950_create_appointments_table',1),(7,'2025_10_04_001000_create_appointment_details_table',1),(8,'2025_10_04_001006_create_payments_table',1),(9,'2025_10_04_014150_create_personal_access_tokens_table',1),(10,'2025_10_04_040214_create_attentions_table',2);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` bigint unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` enum('cash','card','transfer','digital') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','completed','failed','refunded') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'completed',
  `transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payments_appointment_id_foreign` (`appointment_id`),
  CONSTRAINT `payments_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'auth_token','79f05d91b9e6b87a877df1dc77a6d178330617dac0c2c1e83d73eb6ce8e1ba77','[\"*\"]',NULL,NULL,'2025-10-04 07:57:58','2025-10-04 07:57:58'),(2,'App\\Models\\User',1,'auth_token','0b81e9415594e86d310ef63c19a43950eab70e391fa550138db15b11cbcc6d73','[\"*\"]',NULL,NULL,'2025-10-04 09:33:04','2025-10-04 09:33:04'),(3,'App\\Models\\User',1,'auth_token','07fb42701aeec610399512d46c672265d052db243a1eee993d762f2deac91156','[\"*\"]',NULL,NULL,'2025-10-04 10:20:34','2025-10-04 10:20:34'),(4,'App\\Models\\User',1,'auth_token','cc657dfa2bcad9f30240da10cff11e2d649e591e52de5cc722573cd9ecf25f0f','[\"*\"]',NULL,NULL,'2025-10-04 10:29:56','2025-10-04 10:29:56'),(5,'App\\Models\\User',1,'auth_token','0dc2afa14df6661bcaad7e8a1d3711662d9f37e029b2b70ff59d12c1062b3ddd','[\"*\"]','2025-10-04 10:37:23',NULL,'2025-10-04 10:30:11','2025-10-04 10:37:23'),(6,'App\\Models\\User',1,'auth_token','95d6d65726b9540332f9efaddf20d948fb9a86d714ca61bc329ef7d5a1cbd97d','[\"*\"]','2025-10-04 10:54:28',NULL,'2025-10-04 10:32:17','2025-10-04 10:54:28'),(7,'App\\Models\\User',1,'auth_token','05e61a7a894111e3dca553e3672650019a62af158b911b3a4e45d40bac309af3','[\"*\"]','2025-10-04 10:37:41',NULL,'2025-10-04 10:37:41','2025-10-04 10:37:41'),(8,'App\\Models\\User',1,'auth_token','ee8c914913252325649fbcc7f3b0c631d4932e1273ab90ccc1d4a1d1bf44a45c','[\"*\"]','2025-10-04 10:45:38',NULL,'2025-10-04 10:45:38','2025-10-04 10:45:38'),(9,'App\\Models\\User',1,'auth_token','dd9409216ce523edde5878a991fe35cb7fdc8ca7cb813d2ad81fa3da92f6249b','[\"*\"]','2025-10-04 10:46:44',NULL,'2025-10-04 10:46:34','2025-10-04 10:46:44'),(10,'App\\Models\\User',1,'auth_token','76ecf2649e08c3bf0e071692e08c862189b3e59505fcc86a28a0e9c35d9f8881','[\"*\"]','2025-10-04 11:57:01',NULL,'2025-10-04 10:55:27','2025-10-04 11:57:01'),(11,'App\\Models\\User',1,'auth_token','a4378bf8de5870afdd9d662be9e9878efba7eacb1b1456dcb1838d808c045d5c','[\"*\"]','2025-10-04 21:11:36',NULL,'2025-10-04 11:58:33','2025-10-04 21:11:36'),(12,'App\\Models\\User',1,'auth_token','9bba76c704dc47c88114c826c3f79c7167469ae4df70e74b2882cfbc0578ed63','[\"*\"]','2025-10-04 22:11:49',NULL,'2025-10-04 21:12:18','2025-10-04 22:11:49'),(13,'App\\Models\\User',6,'auth_token','a00dcecd5fbbca9062200e4c915cce5703c805fb301af2c53ab4630c1573b869','[\"*\"]',NULL,NULL,'2025-10-05 00:12:19','2025-10-05 00:12:19'),(14,'App\\Models\\User',6,'auth_token','b21dbf829bec582e5b3aa7d39b29bf7f7b0e9e10b8dda3b43bdce8061fb7d853','[\"*\"]',NULL,NULL,'2025-10-05 00:19:25','2025-10-05 00:19:25'),(15,'App\\Models\\User',1,'auth_token','8dc682516c6a637aaad5efa17c4d85392b9fbe07d487528d0bdd6a3041f4a629','[\"*\"]','2025-10-05 00:35:01',NULL,'2025-10-05 00:35:00','2025-10-05 00:35:01'),(16,'App\\Models\\User',1,'auth_token','6a4a3bd09c9ad2400f9b45a84bf5740ae3c4943ee6118d85557438e63ae7fa2b','[\"*\"]','2025-10-05 00:38:12',NULL,'2025-10-05 00:37:21','2025-10-05 00:38:12'),(17,'App\\Models\\User',1,'auth_token','bd66f8c923f5d7a8fe22660c8851b280705e76d054ddab2a4b506d658b0634da','[\"*\"]','2025-10-05 00:55:19',NULL,'2025-10-05 00:55:19','2025-10-05 00:55:19'),(18,'App\\Models\\User',1,'auth_token','780c5ffea66b5a353de6c48d287f8e40f720e97d1f3992ff539e437b194ba84f','[\"*\"]','2025-10-05 01:03:02',NULL,'2025-10-05 00:58:36','2025-10-05 01:03:02'),(19,'App\\Models\\User',1,'auth_token','c40a0ccbf9dc3ad42cd42c7041592dba5da97eb05e725dd5ec2e8973e981cdaa','[\"*\"]','2025-10-05 01:05:28',NULL,'2025-10-05 01:04:01','2025-10-05 01:05:28'),(20,'App\\Models\\User',1,'auth_token','c0505acbd82f3d481288cd78621890a5244c9c11908c9383dc22cab9a42cca88','[\"*\"]','2025-10-05 01:07:18',NULL,'2025-10-05 01:06:44','2025-10-05 01:07:18'),(21,'App\\Models\\User',1,'auth_token','c97a8a3930a3d585cde27c9a82f94e889391d02da7b9d0a26950527e4d765ee2','[\"*\"]','2025-10-05 01:10:35',NULL,'2025-10-05 01:10:03','2025-10-05 01:10:35'),(22,'App\\Models\\User',1,'auth_token','075c45d7cb6e9c337d304efbbdc2b4a5e1b5d0e4a52a78be14a5bece69e72b6d','[\"*\"]','2025-10-05 01:14:46',NULL,'2025-10-05 01:14:00','2025-10-05 01:14:46'),(23,'App\\Models\\User',1,'auth_token','452c4417120cbc8c3885a4c75d0490cdf06eef27104121b7ddc1a6b1b67e6a30','[\"*\"]','2025-10-05 01:17:42',NULL,'2025-10-05 01:17:41','2025-10-05 01:17:42'),(24,'App\\Models\\User',1,'auth_token','598afbbd05e83b409944a2a89b2fe9e7026ca911be7f5fc207476d2b116442e0','[\"*\"]','2025-10-05 01:21:15',NULL,'2025-10-05 01:21:15','2025-10-05 01:21:15'),(25,'App\\Models\\User',1,'auth_token','32c8ee15c07c8dd80072881abf79dcb1083ef3af83906862c8c6ee95b6cd8b0b','[\"*\"]','2025-10-05 01:23:39',NULL,'2025-10-05 01:22:10','2025-10-05 01:23:39'),(26,'App\\Models\\User',1,'auth_token','80da3fb65f7f0d3dd3d6fe29c8d48fa441e6d04de5fe127c8e0cbdd54a81c3e3','[\"*\"]','2025-10-05 01:29:32',NULL,'2025-10-05 01:28:17','2025-10-05 01:29:32'),(27,'App\\Models\\User',1,'auth_token','3e153132ed1c30d5a090273dbe70643067e50a2957935710c66fae8ece3663d1','[\"*\"]','2025-10-05 01:42:53',NULL,'2025-10-05 01:35:05','2025-10-05 01:42:53'),(28,'App\\Models\\User',1,'auth_token','7b9a948532c2f1ada02d079af80689ad39ce4629c6cef0fe07f3a95b6cddc6e8','[\"*\"]','2025-10-05 01:45:15',NULL,'2025-10-05 01:45:15','2025-10-05 01:45:15'),(29,'App\\Models\\User',1,'auth_token','65f86c675431a107ab2f21bd8c91610f022538ce14ec4a3a00c17d6da7ea57a8','[\"*\"]','2025-10-05 01:55:00',NULL,'2025-10-05 01:52:25','2025-10-05 01:55:00'),(30,'App\\Models\\User',1,'auth_token','be55f3c26302634ddfa948971a6074706c780ed287f2ce62ff42f7fa3443feb3','[\"*\"]','2025-10-05 01:55:58',NULL,'2025-10-05 01:55:38','2025-10-05 01:55:58'),(31,'App\\Models\\User',1,'auth_token','8fcc7d8da943bee7642d57186cee4514bcd0e9362bd28561b22c503ea522a008','[\"*\"]','2025-10-05 02:10:39',NULL,'2025-10-05 02:10:07','2025-10-05 02:10:39');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `duration` int NOT NULL COMMENT 'Duración en minutos',
  `price` decimal(10,2) NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (1,'Corte de Cabello Mujer','Corte y peinado para dama',45,25.00,'Cortes',1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(2,'Corte de Cabello Hombre','Corte masculino',30,15.00,'Cortes',1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(3,'Tinte Completo','Coloración completa del cabello',120,60.00,'Coloración',1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(4,'Mechas','Mechas de colores',90,45.00,'Coloración',1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(5,'Peinado de Fiesta','Peinado para eventos especiales',60,35.00,'Peinados',1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(6,'Tratamiento Capilar','Hidratación profunda',45,30.00,'Tratamientos',1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(7,'Manicure','Cuidado de uñas',30,20.00,'Estética',1,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(8,'Pedicure','Cuidado de pies',45,25.00,'Estética',1,'2025-10-04 07:42:54','2025-10-04 07:42:54');
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','stylist','client') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'client',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Anita Pérez','anita@peluqueria.com',NULL,'$2y$12$DCtp2rHwLlsYY8MabfXy0.X2/dljqZkf1RhMqfq9n/k6RH2zpuCmG','admin','555-0001',NULL,1,NULL,'2025-10-04 07:42:53','2025-10-04 07:42:53'),(2,'María González','maria@peluqueria.com',NULL,'$2y$12$LxnSnrMZTpWy9ORaA44egu5qsDiQhd03dhuFE4QarVu82mt71Sbge','stylist','555-0002',NULL,1,NULL,'2025-10-04 07:42:53','2025-10-04 07:42:53'),(3,'Carlos Ruiz','carlos@peluqueria.com',NULL,'$2y$12$ZCiWwKovneRcE/aFkIdFbelpDMXX3U0Z882PnCdLBgYRmIPm6lzqm','stylist','555-0003',NULL,1,NULL,'2025-10-04 07:42:54','2025-10-04 07:42:54'),(6,'Usuario Test','test@test.com',NULL,'$2y$12$k9wcsc3Yi3qVQHr5Hz9xb.PpQtjVrHWf6AZAwwKMN1l9xEMDNPuY.','client','555-1234',NULL,1,NULL,'2025-10-05 00:12:13','2025-10-05 00:12:13');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-04 22:52:10
