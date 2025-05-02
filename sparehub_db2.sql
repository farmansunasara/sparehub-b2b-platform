-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: May 01, 2025 at 08:37 PM
-- Server version: 11.6.2-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sparehub_db2`
--

-- --------------------------------------------------------

--
-- Table structure for table `addresses_address`
--

CREATE TABLE `addresses_address` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address_line1` longtext NOT NULL,
  `address_line2` longtext DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `pincode` varchar(20) NOT NULL,
  `country` varchar(100) NOT NULL,
  `type` varchar(10) NOT NULL,
  `is_default` tinyint(1) NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `addresses_address`
--

INSERT INTO `addresses_address` (`id`, `name`, `phone`, `address_line1`, `address_line2`, `city`, `state`, `pincode`, `country`, `type`, `is_default`, `metadata`, `created_at`, `updated_at`, `user_id`) VALUES
(1, 'meet', '9638521470', 'hsjj', 'bvb', 'jhv', 'vb', '9638521470', 'India', 'home', 0, NULL, '2025-05-01 06:02:13.360775', '2025-05-01 06:02:13.360820', 3);

-- --------------------------------------------------------

--
-- Table structure for table `analytics_analytics`
--

CREATE TABLE `analytics_analytics` (
  `id` bigint(20) NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add content type', 4, 'add_contenttype'),
(14, 'Can change content type', 4, 'change_contenttype'),
(15, 'Can delete content type', 4, 'delete_contenttype'),
(16, 'Can view content type', 4, 'view_contenttype'),
(17, 'Can add session', 5, 'add_session'),
(18, 'Can change session', 5, 'change_session'),
(19, 'Can delete session', 5, 'delete_session'),
(20, 'Can view session', 5, 'view_session'),
(21, 'Can add user', 6, 'add_user'),
(22, 'Can change user', 6, 'change_user'),
(23, 'Can delete user', 6, 'delete_user'),
(24, 'Can view user', 6, 'view_user'),
(25, 'Can add manufacturer', 7, 'add_manufacturer'),
(26, 'Can change manufacturer', 7, 'change_manufacturer'),
(27, 'Can delete manufacturer', 7, 'delete_manufacturer'),
(28, 'Can view manufacturer', 7, 'view_manufacturer'),
(29, 'Can add shop', 8, 'add_shop'),
(30, 'Can change shop', 8, 'change_shop'),
(31, 'Can delete shop', 8, 'delete_shop'),
(32, 'Can view shop', 8, 'view_shop'),
(33, 'Can add brand', 9, 'add_brand'),
(34, 'Can change brand', 9, 'change_brand'),
(35, 'Can delete brand', 9, 'delete_brand'),
(36, 'Can view brand', 9, 'view_brand'),
(37, 'Can add category', 10, 'add_category'),
(38, 'Can change category', 10, 'change_category'),
(39, 'Can delete category', 10, 'delete_category'),
(40, 'Can view category', 10, 'view_category'),
(41, 'Can add product', 11, 'add_product'),
(42, 'Can change product', 11, 'change_product'),
(43, 'Can delete product', 11, 'delete_product'),
(44, 'Can view product', 11, 'view_product'),
(45, 'Can add product image', 12, 'add_productimage'),
(46, 'Can change product image', 12, 'change_productimage'),
(47, 'Can delete product image', 12, 'delete_productimage'),
(48, 'Can view product image', 12, 'view_productimage'),
(49, 'Can add product variant', 13, 'add_productvariant'),
(50, 'Can change product variant', 13, 'change_productvariant'),
(51, 'Can delete product variant', 13, 'delete_productvariant'),
(52, 'Can view product variant', 13, 'view_productvariant'),
(53, 'Can add subcategory', 14, 'add_subcategory'),
(54, 'Can change subcategory', 14, 'change_subcategory'),
(55, 'Can delete subcategory', 14, 'delete_subcategory'),
(56, 'Can view subcategory', 14, 'view_subcategory'),
(57, 'Can add order', 15, 'add_order'),
(58, 'Can change order', 15, 'change_order'),
(59, 'Can delete order', 15, 'delete_order'),
(60, 'Can view order', 15, 'view_order'),
(61, 'Can add order address', 16, 'add_orderaddress'),
(62, 'Can change order address', 16, 'change_orderaddress'),
(63, 'Can delete order address', 16, 'delete_orderaddress'),
(64, 'Can view order address', 16, 'view_orderaddress'),
(65, 'Can add order payment', 17, 'add_orderpayment'),
(66, 'Can change order payment', 17, 'change_orderpayment'),
(67, 'Can delete order payment', 17, 'delete_orderpayment'),
(68, 'Can view order payment', 17, 'view_orderpayment'),
(69, 'Can add order status update', 18, 'add_orderstatusupdate'),
(70, 'Can change order status update', 18, 'change_orderstatusupdate'),
(71, 'Can delete order status update', 18, 'delete_orderstatusupdate'),
(72, 'Can view order status update', 18, 'view_orderstatusupdate'),
(73, 'Can add address', 19, 'add_address'),
(74, 'Can change address', 19, 'change_address'),
(75, 'Can delete address', 19, 'delete_address'),
(76, 'Can view address', 19, 'view_address'),
(77, 'Can add notification', 20, 'add_notification'),
(78, 'Can change notification', 20, 'change_notification'),
(79, 'Can delete notification', 20, 'delete_notification'),
(80, 'Can view notification', 20, 'view_notification'),
(81, 'Can add setting', 21, 'add_setting'),
(82, 'Can change setting', 21, 'change_setting'),
(83, 'Can delete setting', 21, 'delete_setting'),
(84, 'Can view setting', 21, 'view_setting'),
(85, 'Can add analytics', 22, 'add_analytics'),
(86, 'Can change analytics', 22, 'change_analytics'),
(87, 'Can delete analytics', 22, 'delete_analytics'),
(88, 'Can view analytics', 22, 'view_analytics');

-- --------------------------------------------------------

--
-- Table structure for table `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2025-05-01 04:14:37.558496', '1', 'suzuki', 1, '[{\"added\": {}}]', 9, 1),
(2, '2025-05-01 04:15:52.254345', '1', 'bonnet', 1, '[{\"added\": {}}]', 10, 1),
(3, '2025-05-01 04:16:41.584027', '1', 'bonnet - black bonnet', 1, '[{\"added\": {}}]', 14, 1),
(4, '2025-05-01 04:17:13.165064', '1', 'bonnet - black bonnet', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 14, 1),
(5, '2025-05-01 05:57:27.456991', '1', 'bonnet', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(6, '2025-05-01 06:17:43.964806', '1', 'suzuki', 3, '', 9, 1),
(7, '2025-05-01 06:17:56.724336', '2', 'Maruti Suzuki', 1, '[{\"added\": {}}]', 9, 1),
(8, '2025-05-01 06:18:16.747230', '3', 'Hyundai', 1, '[{\"added\": {}}]', 9, 1),
(9, '2025-05-01 06:18:33.736710', '4', 'Tata Motors', 1, '[{\"added\": {}}]', 9, 1),
(10, '2025-05-01 06:18:52.558045', '5', 'Toyota', 1, '[{\"added\": {}}]', 9, 1),
(11, '2025-05-01 06:19:18.049476', '6', 'Kia Motors', 1, '[{\"added\": {}}]', 9, 1),
(12, '2025-05-01 06:22:37.446941', '1', 'bonnet', 3, '', 10, 1),
(13, '2025-05-01 06:22:51.194887', '2', 'Bumpers', 1, '[{\"added\": {}}]', 10, 1),
(14, '2025-05-01 06:23:07.006420', '3', 'Lights', 1, '[{\"added\": {}}]', 10, 1),
(15, '2025-05-01 06:23:19.762163', '4', 'Mirrors', 1, '[{\"added\": {}}]', 10, 1),
(16, '2025-05-01 06:23:31.036362', '5', 'Doors & Handles', 1, '[{\"added\": {}}]', 10, 1),
(17, '2025-05-01 06:23:44.992119', '6', 'Windows & Glass', 1, '[{\"added\": {}}]', 10, 1),
(18, '2025-05-01 06:23:55.597179', '7', 'Fenders', 1, '[{\"added\": {}}]', 10, 1),
(19, '2025-05-01 06:24:20.411197', '8', 'Roof & Body Panels', 1, '[{\"added\": {}}]', 10, 1),
(20, '2025-05-01 06:24:34.698403', '9', 'Exterior Accessories', 1, '[{\"added\": {}}]', 10, 1),
(21, '2025-05-01 06:25:09.465142', '2', 'Bumpers - Front Bumper', 1, '[{\"added\": {}}]', 14, 1),
(22, '2025-05-01 06:25:29.396655', '2', 'Bumpers - Front Bumper', 2, '[]', 14, 1),
(23, '2025-05-01 06:25:58.638885', '3', 'Bumpers - Rear Bumper', 1, '[{\"added\": {}}]', 14, 1),
(24, '2025-05-01 06:26:12.939006', '4', 'Lights - Headlights', 1, '[{\"added\": {}}]', 14, 1),
(25, '2025-05-01 06:26:28.525223', '5', 'Lights - Tail Lights', 1, '[{\"added\": {}}]', 14, 1),
(26, '2025-05-01 06:26:46.854532', '6', 'Lights - Fog Lights', 1, '[{\"added\": {}}]', 14, 1),
(27, '2025-05-01 06:27:02.237328', '7', 'Lights - Indicators', 1, '[{\"added\": {}}]', 14, 1),
(28, '2025-05-01 06:27:22.356714', '8', 'Mirrors - Side Mirrors', 1, '[{\"added\": {}}]', 14, 1),
(29, '2025-05-01 06:27:35.095971', '9', 'Mirrors - Rear View Mirror', 1, '[{\"added\": {}}]', 14, 1),
(30, '2025-05-01 06:27:51.533508', '10', 'Doors & Handles - Front Door', 1, '[{\"added\": {}}]', 14, 1),
(31, '2025-05-01 06:28:02.605874', '11', 'Doors & Handles - Rear Door', 1, '[{\"added\": {}}]', 14, 1),
(32, '2025-05-01 06:28:15.438049', '12', 'Doors & Handles - Door Handles', 1, '[{\"added\": {}}]', 14, 1),
(33, '2025-05-01 06:28:33.507114', '13', 'Windows & Glass - Windshield (Front & Rear)', 1, '[{\"added\": {}}]', 14, 1),
(34, '2025-05-01 06:28:48.250820', '14', 'Windows & Glass - Side Window Glass', 1, '[{\"added\": {}}]', 14, 1),
(35, '2025-05-01 06:29:27.851371', '7', 'Fenders', 3, '', 10, 1),
(36, '2025-05-01 06:30:04.979779', '15', 'Roof & Body Panels - Roof Rails', 1, '[{\"added\": {}}]', 14, 1),
(37, '2025-05-01 06:30:20.820817', '16', 'Roof & Body Panels - Side Panels', 1, '[{\"added\": {}}]', 14, 1),
(38, '2025-05-01 06:30:39.845648', '17', 'Exterior Accessories - Spoilers', 1, '[{\"added\": {}}]', 14, 1),
(39, '2025-05-01 06:30:53.897539', '18', 'Exterior Accessories - Mud Flaps', 1, '[{\"added\": {}}]', 14, 1),
(40, '2025-05-01 06:31:07.230471', '19', 'Exterior Accessories - Side Steps', 1, '[{\"added\": {}}]', 14, 1),
(41, '2025-05-01 07:48:01.554473', '7', 'Sunroof Glass Panel', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(42, '2025-05-01 07:48:25.501420', '6', 'Premium Alloy Car Side Step', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(43, '2025-05-01 07:48:55.060979', '5', 'TurboShield Bonnet – Maruti Swift (2018-2022)', 2, '[{\"changed\": {\"fields\": [\"Is featured\", \"Is approved\"]}}]', 11, 1),
(44, '2025-05-01 07:49:06.981371', '7', 'Sunroof Glass Panel', 2, '[{\"changed\": {\"fields\": [\"Is featured\"]}}]', 11, 1),
(45, '2025-05-01 07:49:12.579266', '5', 'TurboShield Bonnet – Maruti Swift (2018-2022)', 2, '[]', 11, 1),
(46, '2025-05-01 07:49:19.147344', '6', 'Premium Alloy Car Side Step', 2, '[{\"changed\": {\"fields\": [\"Is featured\"]}}]', 11, 1),
(47, '2025-05-01 07:49:30.079481', '4', 'Xenon Blaze H4 Headlight', 2, '[{\"changed\": {\"fields\": [\"Is featured\", \"Is approved\"]}}]', 11, 1),
(48, '2025-05-01 07:49:49.324073', '3', 'Front Bumper for Maruti Suzuki Swift (2018-2023) OEM Grade', 2, '[{\"changed\": {\"fields\": [\"Description\", \"Is featured\", \"Is approved\"]}}]', 11, 1),
(49, '2025-05-01 07:50:04.744941', '2', 'Front Left Door Panel â Maruti Suzuki Swift (2018-2023)', 2, '[{\"changed\": {\"fields\": [\"Description\", \"Is featured\", \"Is approved\"]}}]', 11, 1),
(50, '2025-05-01 07:50:13.680109', '3', 'Front Bumper for Maruti Suzuki Swift (2018-2023) OEM Grade', 2, '[]', 11, 1),
(51, '2025-05-01 07:50:21.712573', '4', 'Xenon Blaze H4 Headlight', 2, '[]', 11, 1),
(52, '2025-05-01 07:55:43.734950', '8', 'Roof & Body Panels', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(53, '2025-05-01 07:56:48.680064', '9', 'Exterior Accessories', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(54, '2025-05-01 07:58:58.707356', '4', 'Mirrors', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(55, '2025-05-01 08:00:38.170419', '3', 'Lights', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(56, '2025-05-01 08:02:44.300814', '2', 'Bumpers', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(57, '2025-05-01 08:03:49.804428', '2', 'Bumpers', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(58, '2025-05-01 08:05:22.081916', '5', 'Doors & Handles', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(59, '2025-05-01 08:06:39.683118', '6', 'Windows & Glass', 2, '[{\"changed\": {\"fields\": [\"Image\"]}}]', 10, 1),
(60, '2025-05-01 08:07:30.731772', '4', 'Mirrors       .', 2, '[{\"changed\": {\"fields\": [\"Name\"]}}]', 10, 1),
(61, '2025-05-01 08:07:49.543085', '3', 'Lights       .', 2, '[{\"changed\": {\"fields\": [\"Name\"]}}]', 10, 1),
(62, '2025-05-01 08:08:38.573814', '3', 'Lights', 2, '[{\"changed\": {\"fields\": [\"Name\"]}}]', 10, 1),
(63, '2025-05-01 08:08:51.022001', '4', 'Mirrors', 2, '[{\"changed\": {\"fields\": [\"Name\"]}}]', 10, 1),
(64, '2025-05-01 08:20:28.884325', '1', 'Order 1 by mit@gmail.com', 3, '', 15, 1),
(65, '2025-05-01 08:20:55.336260', '1', 'meet - jhv', 3, '', 16, 1),
(66, '2025-05-01 08:21:06.332777', '1', 'cod - pending - 2594.64', 3, '', 17, 1),
(67, '2025-05-01 12:27:48.213906', '9', 'Innova Crysta Rear Bumper – Matte Black', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(68, '2025-05-01 12:28:11.388443', '8', 'Front Left Side Door Glass - Maruti Suzuki Swift', 2, '[{\"changed\": {\"fields\": [\"Is featured\", \"Is approved\"]}}]', 11, 1),
(69, '2025-05-01 12:51:14.272619', '11', 'Front and Rear Bumper Guards', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(70, '2025-05-01 12:51:20.124257', '10', 'Door Panels (Left & Right, Front & Rear)', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(71, '2025-05-01 12:58:27.070469', '12', 'Door Visor for Maruti Suzuki Swift by AutoFurnish', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(72, '2025-05-01 13:14:11.108972', '3', 'cod - pending - 153990.00', 2, '[]', 17, 1),
(73, '2025-05-01 13:16:56.423141', '7', 'Force Motors', 1, '[{\"added\": {}}]', 9, 1),
(74, '2025-05-01 13:17:19.165469', '14', 'Front Bumper for Maruti Suzuki Swift (2018-2023 Model)', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(75, '2025-05-01 13:17:24.905007', '13', 'Philips X-tremeVision G-force H4 Car Headlight Bulb – 12V 60/55W', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(76, '2025-05-01 13:18:46.607116', '8', 'volvo', 1, '[{\"added\": {}}]', 9, 1),
(77, '2025-05-01 13:21:36.428954', '10', 'Suspension & Steering', 1, '[{\"added\": {}}]', 10, 1),
(78, '2025-05-01 13:22:19.958186', '20', 'Suspension & Steering - Shock Absorbers', 1, '[{\"added\": {}}]', 14, 1),
(79, '2025-05-01 13:22:50.010944', '21', 'Suspension & Steering - Steering Rock', 1, '[{\"added\": {}}]', 14, 1),
(80, '2025-05-01 13:32:30.625021', '16', 'Steering Rack Assembly – Maruti Suzuki Swift (2018 Model) by Sona Koyo Steering Systems', 2, '[{\"changed\": {\"fields\": [\"Is approved\"]}}]', 11, 1),
(81, '2025-05-01 13:32:37.394986', '15', 'Monroe Original Rear Shock Absorber', 2, '[{\"changed\": {\"fields\": [\"Description\", \"Is approved\"]}}]', 11, 1);

-- --------------------------------------------------------

--
-- Table structure for table `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(19, 'addresses', 'address'),
(1, 'admin', 'logentry'),
(22, 'analytics', 'analytics'),
(3, 'auth', 'group'),
(2, 'auth', 'permission'),
(4, 'contenttypes', 'contenttype'),
(20, 'notifications', 'notification'),
(15, 'orders', 'order'),
(16, 'orders', 'orderaddress'),
(17, 'orders', 'orderpayment'),
(18, 'orders', 'orderstatusupdate'),
(9, 'products', 'brand'),
(10, 'products', 'category'),
(11, 'products', 'product'),
(12, 'products', 'productimage'),
(13, 'products', 'productvariant'),
(14, 'products', 'subcategory'),
(5, 'sessions', 'session'),
(21, 'settings', 'setting'),
(7, 'users', 'manufacturer'),
(8, 'users', 'shop'),
(6, 'users', 'user');

-- --------------------------------------------------------

--
-- Table structure for table `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2025-05-01 04:07:44.386947'),
(2, 'contenttypes', '0002_remove_content_type_name', '2025-05-01 04:07:44.524075'),
(3, 'auth', '0001_initial', '2025-05-01 04:07:45.110222'),
(4, 'auth', '0002_alter_permission_name_max_length', '2025-05-01 04:07:45.253011'),
(5, 'auth', '0003_alter_user_email_max_length', '2025-05-01 04:07:45.262889'),
(6, 'auth', '0004_alter_user_username_opts', '2025-05-01 04:07:45.283473'),
(7, 'auth', '0005_alter_user_last_login_null', '2025-05-01 04:07:45.293563'),
(8, 'auth', '0006_require_contenttypes_0002', '2025-05-01 04:07:45.299353'),
(9, 'auth', '0007_alter_validators_add_error_messages', '2025-05-01 04:07:45.309361'),
(10, 'auth', '0008_alter_user_username_max_length', '2025-05-01 04:07:45.320516'),
(11, 'auth', '0009_alter_user_last_name_max_length', '2025-05-01 04:07:45.330408'),
(12, 'auth', '0010_alter_group_name_max_length', '2025-05-01 04:07:45.392117'),
(13, 'auth', '0011_update_proxy_permissions', '2025-05-01 04:07:45.408836'),
(14, 'auth', '0012_alter_user_first_name_max_length', '2025-05-01 04:07:45.421277'),
(15, 'users', '0001_initial', '2025-05-01 04:07:46.403060'),
(16, 'addresses', '0001_initial', '2025-05-01 04:07:46.446476'),
(17, 'addresses', '0002_initial', '2025-05-01 04:07:46.553107'),
(18, 'admin', '0001_initial', '2025-05-01 04:07:46.839071'),
(19, 'admin', '0002_logentry_remove_auto_add', '2025-05-01 04:07:46.855785'),
(20, 'admin', '0003_logentry_add_action_flag_choices', '2025-05-01 04:07:46.893193'),
(21, 'analytics', '0001_initial', '2025-05-01 04:07:46.929223'),
(22, 'analytics', '0002_initial', '2025-05-01 04:07:47.029293'),
(23, 'notifications', '0001_initial', '2025-05-01 04:07:47.069930'),
(24, 'notifications', '0002_initial', '2025-05-01 04:07:47.176325'),
(25, 'orders', '0001_initial', '2025-05-01 04:07:47.440064'),
(26, 'orders', '0002_initial', '2025-05-01 04:07:48.347688'),
(27, 'products', '0001_initial', '2025-05-01 04:07:49.902430'),
(28, 'sessions', '0001_initial', '2025-05-01 04:07:49.996379'),
(29, 'settings', '0001_initial', '2025-05-01 04:07:50.031791'),
(30, 'settings', '0002_initial', '2025-05-01 04:07:50.226300');

-- --------------------------------------------------------

--
-- Table structure for table `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('vuadfslrtxrtr7hd3x37yl0t1qivphwm', '.eJxVjDsOwyAQBe9CHSEwyy9lep8BLSwKTiKQjF1FuXuw5CJpZ-a9Nwu4byXsPa9hIXZlkl1-WcT0zPUQ9MB6bzy1uq1L5EfCT9v53Ci_bmf7d1Cwl7FGlHIiq5TTpICsBkrSZANiMAHeR8QIaMANqcg6RZMgnVCSJq8F-3wBxpU3NA:1uALII:vkRARMJCS3oJXJZ-oij0GzdHx3sdjIugxmGU6adPn_0', '2025-05-15 04:13:06.793882');

-- --------------------------------------------------------

--
-- Table structure for table `notifications_notification`
--

CREATE TABLE `notifications_notification` (
  `id` bigint(20) NOT NULL,
  `type` varchar(20) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` longtext NOT NULL,
  `is_read` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders_order`
--

CREATE TABLE `orders_order` (
  `id` bigint(20) NOT NULL,
  `shop_name` varchar(255) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `status` varchar(20) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `tax` decimal(10,2) NOT NULL,
  `shipping_cost` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `user_id` int(11) NOT NULL,
  `billing_address_id` bigint(20) DEFAULT NULL,
  `shipping_address_id` bigint(20) NOT NULL,
  `payment_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders_order`
--

INSERT INTO `orders_order` (`id`, `shop_name`, `items`, `status`, `subtotal`, `tax`, `shipping_cost`, `total`, `created_at`, `updated_at`, `metadata`, `user_id`, `billing_address_id`, `shipping_address_id`, `payment_id`) VALUES
(2, 'SpareHub Shop', '[{\"product_id\": \"3\", \"quantity\": 10, \"price\": 2500.0}, {\"product_id\": \"7\", \"quantity\": 5, \"price\": 6000.0}]', 'pending', 55000.00, 9900.00, 0.00, 64900.00, '2025-05-01 09:41:58.703605', '2025-05-01 09:41:58.703657', '{\"checkout_timestamp\": \"2025-05-01T15:11:58.679420\"}', 3, NULL, 2, 2),
(3, 'SpareHub Shop', '[{\"product_id\": \"6\", \"quantity\": 12, \"price\": 4000.0}, {\"product_id\": \"4\", \"quantity\": 15, \"price\": 2000.0}, {\"product_id\": \"5\", \"quantity\": 15, \"price\": 3500.0}]', 'pending', 130500.00, 23490.00, 0.00, 153990.00, '2025-05-01 09:45:57.361588', '2025-05-01 09:45:57.361639', '{\"checkout_timestamp\": \"2025-05-01T15:15:57.185772\"}', 3, NULL, 3, 3),
(4, 'SpareHub Shop', '[{\"product_id\": \"7\", \"quantity\": 1, \"price\": 6000.0}, {\"product_id\": \"2\", \"quantity\": 1, \"price\": 15000.0}, {\"product_id\": \"3\", \"quantity\": 1, \"price\": 2500.0}, {\"product_id\": \"4\", \"quantity\": 1, \"price\": 2000.0}]', 'pending', 25500.00, 4590.00, 0.00, 30090.00, '2025-05-01 17:05:54.414417', '2025-05-01 17:05:54.414501', '{\"checkout_timestamp\": \"2025-05-01T22:35:53.240854\"}', 3, NULL, 4, 4);

-- --------------------------------------------------------

--
-- Table structure for table `orders_orderaddress`
--

CREATE TABLE `orders_orderaddress` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address_line1` longtext NOT NULL,
  `address_line2` longtext DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `pincode` varchar(20) NOT NULL,
  `country` varchar(100) NOT NULL,
  `is_default` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders_orderaddress`
--

INSERT INTO `orders_orderaddress` (`id`, `name`, `phone`, `address_line1`, `address_line2`, `city`, `state`, `pincode`, `country`, `is_default`) VALUES
(2, 'meet', '9638521470', 'hsjj', 'bvb', 'jhv', 'vb', '9638521470', 'India', 0),
(3, 'meet', '9638521470', 'hsjj', 'bvb', 'jhv', 'vb', '9638521470', 'India', 0),
(4, 'meet', '9638521470', 'hsjj', 'bvb', 'jhv', 'vb', '9638521470', 'India', 0);

-- --------------------------------------------------------

--
-- Table structure for table `orders_orderpayment`
--

CREATE TABLE `orders_orderpayment` (
  `id` bigint(20) NOT NULL,
  `method` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `timestamp` datetime(6) NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders_orderpayment`
--

INSERT INTO `orders_orderpayment` (`id`, `method`, `status`, `amount`, `transaction_id`, `timestamp`, `metadata`) VALUES
(2, 'cod', 'pending', 64900.00, NULL, '2025-05-01 09:41:58.697043', NULL),
(3, 'cod', 'pending', 153990.00, NULL, '2025-05-01 09:45:57.355734', NULL),
(4, 'cod', 'pending', 30090.00, NULL, '2025-05-01 17:05:54.398319', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `orders_orderstatusupdate`
--

CREATE TABLE `orders_orderstatusupdate` (
  `id` bigint(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `comment` longtext DEFAULT NULL,
  `timestamp` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders_order_status_updates`
--

CREATE TABLE `orders_order_status_updates` (
  `id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `orderstatusupdate_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products_brand`
--

CREATE TABLE `products_brand` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `logo` varchar(100) DEFAULT NULL,
  `description` longtext NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products_brand`
--

INSERT INTO `products_brand` (`id`, `name`, `logo`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(2, 'Maruti Suzuki', '', '', 1, '2025-05-01 06:17:56.721979', '2025-05-01 06:17:56.722035'),
(3, 'Hyundai', '', '', 1, '2025-05-01 06:18:16.743458', '2025-05-01 06:18:16.743551'),
(4, 'Tata Motors', '', '', 1, '2025-05-01 06:18:33.733947', '2025-05-01 06:18:33.734013'),
(5, 'Toyota', '', '', 1, '2025-05-01 06:18:52.555911', '2025-05-01 06:18:52.555967'),
(6, 'Kia Motors', 'brands/download.png', '', 1, '2025-05-01 06:19:18.046253', '2025-05-01 06:19:18.046340'),
(7, 'Force Motors', '', '', 1, '2025-05-01 13:16:56.421921', '2025-05-01 13:16:56.421952'),
(8, 'volvo', '', '', 1, '2025-05-01 13:18:46.605363', '2025-05-01 13:18:46.605412');

-- --------------------------------------------------------

--
-- Table structure for table `products_category`
--

CREATE TABLE `products_category` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `image` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products_category`
--

INSERT INTO `products_category` (`id`, `name`, `slug`, `image`, `is_active`, `created_at`, `updated_at`) VALUES
(2, 'Bumpers', 'bumpers', 'categories/images_P3jIBlV.jpg', 1, '2025-05-01 06:22:51.193075', '2025-05-01 08:03:49.800710'),
(3, 'Lights', 'lights', 'categories/images.jpg', 1, '2025-05-01 06:23:07.005392', '2025-05-01 08:08:38.569840'),
(4, 'Mirrors', 'mirrors', 'categories/download_kSVG2Po.png', 1, '2025-05-01 06:23:19.760939', '2025-05-01 08:08:51.019380'),
(5, 'Doors & Handles', 'doors-handles', 'categories/download_pT27DwE.jpg', 1, '2025-05-01 06:23:31.035219', '2025-05-01 08:05:22.078097'),
(6, 'Windows & Glass', 'windows-glass', 'categories/download_Q0TIx9b.jpg', 1, '2025-05-01 06:23:44.991109', '2025-05-01 08:06:39.678546'),
(8, 'Roof & Body Panels', 'roof-body-panels', 'categories/download.jpg', 1, '2025-05-01 06:24:20.410032', '2025-05-01 07:55:43.731154'),
(9, 'Exterior Accessories', 'exterior-accessories', 'categories/download.png', 1, '2025-05-01 06:24:34.697114', '2025-05-01 07:56:48.674866'),
(10, 'Suspension & Steering', 'suspension-steering', 'categories/red-3-spoke-sporty-and-stylish-oem-original-imaeb4uf9t7ze2az.png', 1, '2025-05-01 13:21:36.426934', '2025-05-01 13:21:36.426976');

-- --------------------------------------------------------

--
-- Table structure for table `products_product`
--

CREATE TABLE `products_product` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` longtext NOT NULL,
  `sku` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `discount` decimal(5,2) NOT NULL,
  `stock_quantity` int(10) UNSIGNED NOT NULL CHECK (`stock_quantity` >= 0),
  `min_order_quantity` int(10) UNSIGNED NOT NULL CHECK (`min_order_quantity` >= 0),
  `max_order_quantity` int(10) UNSIGNED DEFAULT NULL CHECK (`max_order_quantity` >= 0),
  `weight` decimal(10,2) NOT NULL,
  `dimensions` varchar(100) NOT NULL,
  `material` varchar(255) NOT NULL,
  `color` varchar(100) NOT NULL,
  `technical_specification_pdf` varchar(100) DEFAULT NULL,
  `installation_guide_pdf` varchar(100) DEFAULT NULL,
  `shipping_cost` decimal(10,2) NOT NULL,
  `shipping_time` varchar(100) NOT NULL,
  `origin_country` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_featured` tinyint(1) NOT NULL,
  `is_approved` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `brand_id` bigint(20) DEFAULT NULL,
  `category_id` bigint(20) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `subcategory_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products_product`
--

INSERT INTO `products_product` (`id`, `name`, `description`, `sku`, `price`, `discount`, `stock_quantity`, `min_order_quantity`, `max_order_quantity`, `weight`, `dimensions`, `material`, `color`, `technical_specification_pdf`, `installation_guide_pdf`, `shipping_cost`, `shipping_time`, `origin_country`, `is_active`, `is_featured`, `is_approved`, `created_at`, `updated_at`, `brand_id`, `category_id`, `manufacturer_id`, `subcategory_id`) VALUES
(2, 'Front Left Door Panel â Maruti Suzuki Swift (2018-2023)', 'High-quality replacement front left door panel compatible with Maruti Suzuki Swift models from 2018 to 2023. Manufactured with precision to match OEM specifications, ensuring a perfect fit and finish. The panel comes with primed surface ready for painting, reinforced hinges, and slots for power window and mirror assemblies. Ideal for accident repairs or rust replacements.\r\n\r\nPosition: Front Left (Driver Side)\r\n\r\nMaterial: High-Grade Steel\r\n\r\nFinish: Unpainted, Primer Coated\r\n\r\nCompatibility: Maruti Suzuki Swift (2018â2023)\r\n\r\nWarranty: 6 Months against manufacturing defects', 'MS-SWIFT-FLD-18-23-BLK', 15000.00, 15.00, 16, 2, 10, 41.00, '12x13x24', 'Mattel', 'black', '', '', 0.00, '', '', 1, 1, 1, '2025-05-01 06:53:40.926210', '2025-05-01 07:50:04.739464', 2, 5, 4, 10),
(3, 'Front Bumper for Maruti Suzuki Swift (2018-2023) OEM Grade', 'Upgrade or replace your damaged bumper with this high-quality OEM-grade front bumper designed for Maruti Suzuki Swift (2018â2023 models). Built with durable ABS plastic for maximum impact resistance and longevity. Perfectly fits with original mounting points â no modification required. Primed and ready for painting to match your carâs color. Ideal for both replacements and custom upgrades.\r\n\r\nMaterial: Premium ABS Plastic\r\n\r\nFinish: Primed (Ready for Paint)\r\n\r\nFitment: Direct OEM Replacement', '06ASDFG5432N1Z6', 2500.00, 20.00, 150, 10, 100, 20.00, '12x23x12', 'Mattel', 'black', '', '', 0.00, '', '', 1, 1, 1, '2025-05-01 07:03:48.838251', '2025-05-01 07:50:13.676357', 2, 2, 4, 2),
(4, 'Xenon Blaze H4 Headlight', 'High-intensity Xenon headlight with 6000K brightness for clear night vision. Designed for long-lasting performance and better road visibility, compatible with most sedans and hatchbacks.', 'HL-XB-H4-6000K', 2000.00, 40.00, 250, 15, 150, 15.00, '12x34x42', 'metter', 'black', '', '', 0.00, '', '', 1, 1, 1, '2025-05-01 07:13:30.753933', '2025-05-01 07:50:21.707416', 6, 3, 4, 4),
(5, 'TurboShield Bonnet – Maruti Swift (2018-2022)', 'Premium-grade metal bonnet designed specifically for Maruti Swift models (2018–2022). Ensures perfect fit, high durability, and resistance to dents and corrosion. Coated with rust-proof primer for long-lasting performance.', 'BON-I20-AF-20PL', 3500.00, 15.00, 350, 15, 150, 15.00, '12x13x23', 'mattel', 'black', '', '', 0.00, '', '', 1, 1, 1, '2025-05-01 07:20:16.512596', '2025-05-01 07:49:12.574965', 2, 2, 4, 3),
(6, 'Premium Alloy Car Side Step', 'The Premium Alloy Car Side Step is a high-quality, durable accessory designed to provide ease of access to your vehicle. Ideal for both SUVs and trucks, these side steps are crafted from reinforced alloy material to withstand heavy usage and harsh weather conditions. The sleek, stylish design enhances the appearance of your vehicle while offering a non-slip surface for safe and secure entry and exit.', 'BON-I20-AF-20PK', 4000.00, 25.00, 800, 12, 150, 8.00, '23x13x43', 'Mattel', 'black', '', '', 0.00, '', '', 1, 1, 1, '2025-05-01 07:38:25.191072', '2025-05-01 07:49:19.143129', 5, 9, 4, 19),
(7, 'Sunroof Glass Panel', 'Tempered glass panel that slides open to allow light and air into the cabin. Designed for vehicles with automatic or manual sunroof mechanisms.', 'BON-I20-AF-20PA', 6000.00, 45.00, 250, 5, 100, 9.00, '23x12x45', 'Mattel', 'white', '', '', 0.00, '', '', 1, 1, 1, '2025-05-01 07:41:50.404933', '2025-05-01 07:49:06.976327', 4, 8, 4, 15),
(8, 'Front Left Side Door Glass - Maruti Suzuki Swift', 'High-quality tempered front left side door glass compatible with Maruti Suzuki Swift models (2012–2022). This OEM-grade window offers excellent visibility, UV resistance, and perfect fitment with factory-fitted doors. Designed to withstand road vibrations and weather conditions, ensuring long-term durability and safety. Easy to install and resistant to scratches and shattering.', 'SWF-LFT-WND-GLS-12', 2500.00, 10.00, 250, 15, 150, 12.00, '23x12x56', 'glass', 'black', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 08:31:45.130895', '2025-05-01 12:28:11.385185', 5, 6, 5, 13),
(9, 'Innova Crysta Rear Bumper – Matte Black', 'Heavy-duty rear bumper for Toyota Innova Crysta. Scratch-resistant matte finish with integrated reflector slots for added safety.', '07PQRSX5678L1Z3', 3500.00, 20.00, 300, 20, 150, 15.00, '12x34x13', 'Mattel', 'black', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 12:26:21.841702', '2025-05-01 12:27:48.208591', 5, 2, 5, 3),
(10, 'Door Panels (Left & Right, Front & Rear)', 'The outer metal shell of the car doors, available for all four sides and designed to protect and provide entry.', '09MNBVC3456U1Z4', 4500.00, 10.00, 210, 10, 100, 19.00, '23x12x43', 'Mattel', 'Cream', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 12:40:04.081322', '2025-05-01 12:51:20.122526', 6, 5, 6, 10),
(11, 'Front and Rear Bumper Guards', 'Provides extra protection against minor bumps and scratches. Stylish and sturdy design.', '09MNBVC3456U1Z8', 350.00, 5.00, 500, 100, 300, 1.00, '13x24x35', 'plastic', 'black', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 12:46:54.776372', '2025-05-01 12:51:14.270726', 2, 2, 6, 3),
(12, 'Door Visor for Maruti Suzuki Swift by AutoFurnish', 'Enhance your Maruti Suzuki Swift’s appearance and driving comfort with AutoFurnish’s high-quality door visors. These visors are crafted from durable, shatterproof acrylic material with a sleek black and chrome finish. Designed specifically for Swift models (2018 onwards), they help deflect rain, dust, and wind while allowing fresh air circulation. Easy to install with 3M double-sided tape, they also add a stylish touch to the vehicle’s side profile. This product ensures perfect fitment and weather protection without compromising aesthetics.', '21ZXCVB9876Y1Z2', 2000.00, 5.00, 500, 100, 300, 3.00, '17x12x15', 'plastic', 'black, grey, green', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 12:57:31.290219', '2025-05-01 12:58:27.068576', 2, 9, 6, 17),
(13, 'Philips X-tremeVision G-force H4 Car Headlight Bulb – 12V 60/55W', 'Experience up to 130% brighter light with the Philips X-tremeVision G-force H4 headlight bulb. Specially designed for improved night driving, it offers a longer beam and enhanced visibility without dazzling other drivers. This halogen bulb is engineered to resist vibration and works with most cars that support H4 headlamp sockets. Its robust filament design ensures better durability, making it ideal for Indian road conditions. Trusted by leading automakers, Philips brings OE-quality lighting that complies with high safety standards. Perfect for vehicles like Maruti Suzuki Swift, Hyundai i20, Honda City, Tata Nexon, and more.', '21ZXCVB9876Y1Y1', 650.00, 10.00, 600, 100, 400, 1.00, '', '', '', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 13:04:50.721686', '2025-05-01 13:17:24.902341', 5, 3, 6, 5),
(14, 'Front Bumper for Maruti Suzuki Swift (2018-2023 Model)', 'This high-quality front bumper is specifically designed for the Maruti Suzuki Swift (3rd Gen, 2018–2023). Made from durable ABS plastic, it offers excellent impact resistance and a perfect factory-style fit. The bumper comes with slots for fog lamps, number plate, and air vents, and is primed for painting. Ideal for replacements due to damage or wear, it ensures both safety and a refreshed look. Compatible with both petrol and diesel variants.', '24WXYZA6789T1ZM', 20000.00, 40.00, 400, 100, 240, 20.00, '12x34x56', 'plastic', 'black , white , blue', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 13:16:08.631578', '2025-05-01 13:17:19.163628', 2, 2, 7, 2),
(15, 'Monroe Original Rear Shock Absorber', 'The Monroe Original Rear Shock Absorber is engineered to deliver excellent handling and comfort for the Maruti Suzuki Swift. Designed using OE (Original Equipment) specifications, it ensures a perfect fit and long-lasting performance. Monroe uses advanced valving technology and high-quality components to absorb road impacts effectively, reducing vibrations and improving vehicle stability. Ideal for both city and highway driving, this shock absorber enhances braking response and cornering safety. Backed by Monroe’s global reputation, it\'s a reliable replacement part trusted by workshops and car owners alike.\r\n\r\nBrand: Monroe\r\n\r\nModel Compatibility: Maruti Suzuki Swift (Petrol/Diesel – All Variants)\r\n\r\nPosition: Rear\r\n\r\nPart Number: 239002-SP\r\n\r\nType: Gas-filled Twin Tube\r\n\r\nWarranty: 1 Year Manufacturer Warranty', '33QWERT1234R1Z9', 2069.00, 20.00, 500, 100, 400, 4.00, '12x34x56', 'Mattel', 'black', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 13:27:57.039309', '2025-05-01 13:32:37.393158', 8, 10, 7, 20),
(16, 'Steering Rack Assembly – Maruti Suzuki Swift (2018 Model) by Sona Koyo Steering Systems', 'This is a high-quality steering rack assembly specifically designed for the Maruti Suzuki Swift (2018 model), manufactured by Sona Koyo Steering Systems, one of India’s leading OEM suppliers. The steering rack is a vital component of the vehicle\'s steering system, converting the rotational motion of the steering wheel into the linear motion needed to turn the wheels. It ensures precise handling, improved road feedback, and enhanced driver control. Made from durable, corrosion-resistant materials, this rack is engineered for long-lasting performance and is ideal for both city and highway driving. Fully compatible with the Swift’s power steering system, it meets all OEM specifications for safety and performance.', '33QWERT1234R1ZS', 4000.00, 20.00, 400, 100, 300, 10.00, '12x35x64', 'Mattel', 'black', '', '', 0.00, '', '', 1, 0, 1, '2025-05-01 13:32:12.957967', '2025-05-01 13:32:30.623369', 2, 10, 7, 21);

-- --------------------------------------------------------

--
-- Table structure for table `products_productimage`
--

CREATE TABLE `products_productimage` (
  `id` bigint(20) NOT NULL,
  `image` varchar(100) DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `product_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products_productimage`
--

INSERT INTO `products_productimage` (`id`, `image`, `is_primary`, `created_at`, `product_id`) VALUES
(7, 'product_images/scaled_1000325887.jpg', 1, '2025-05-01 06:59:25.025205', 2),
(8, 'product_images/scaled_1000325886.jpg', 0, '2025-05-01 06:59:25.031094', 2),
(9, 'product_images/scaled_1000325885_ptzSey0.jpg', 0, '2025-05-01 06:59:25.033877', 2),
(10, 'product_images/scaled_1000325884_uv4bL1P.jpg', 0, '2025-05-01 06:59:25.037791', 2),
(15, 'product_images/scaled_1000325889_hB8tPfJ.jpg', 1, '2025-05-01 07:04:43.733183', 3),
(16, 'product_images/scaled_1000325892_BAEa1wH.jpg', 0, '2025-05-01 07:04:43.736521', 3),
(17, 'product_images/scaled_1000325891_niPu4n0.jpg', 0, '2025-05-01 07:04:43.740320', 3),
(18, 'product_images/scaled_1000325890_rqod0wm.jpg', 0, '2025-05-01 07:04:43.742904', 3),
(19, 'product_images/scaled_1000325894.jpg', 1, '2025-05-01 07:13:30.763843', 4),
(20, 'product_images/scaled_1000325896.jpg', 0, '2025-05-01 07:13:30.768131', 4),
(21, 'product_images/scaled_1000325893.jpg', 0, '2025-05-01 07:13:30.772375', 4),
(22, 'product_images/scaled_1000325895.jpg', 0, '2025-05-01 07:13:30.776260', 4),
(23, 'product_images/scaled_1000325897.jpg', 1, '2025-05-01 07:20:16.528578', 5),
(24, 'product_images/scaled_1000325899.jpg', 0, '2025-05-01 07:20:16.533641', 5),
(25, 'product_images/scaled_1000325898.jpg', 0, '2025-05-01 07:20:16.541341', 5),
(26, 'product_images/scaled_1000325902.jpg', 1, '2025-05-01 07:38:25.199404', 6),
(27, 'product_images/scaled_1000325901.jpg', 0, '2025-05-01 07:38:25.207358', 6),
(28, 'product_images/scaled_1000325900.jpg', 0, '2025-05-01 07:38:25.212834', 6),
(29, 'product_images/scaled_1000325905.jpg', 1, '2025-05-01 07:41:50.418160', 7),
(30, 'product_images/scaled_1000325903.jpg', 0, '2025-05-01 07:41:50.426253', 7),
(31, 'product_images/scaled_1000325904.jpg', 0, '2025-05-01 07:41:50.431960', 7),
(32, 'product_images/scaled_1000325916.jpg', 1, '2025-05-01 08:31:45.140262', 8),
(33, 'product_images/scaled_1000325917.jpg', 0, '2025-05-01 08:31:45.143423', 8),
(34, 'product_images/scaled_1000325918.jpg', 0, '2025-05-01 08:31:45.148158', 8),
(35, 'product_images/scaled_1000325970.png', 1, '2025-05-01 12:26:21.857147', 9),
(36, 'product_images/scaled_1000325971.jpg', 0, '2025-05-01 12:26:21.884416', 9),
(37, 'product_images/scaled_1000325972.jpg', 0, '2025-05-01 12:26:21.892330', 9),
(38, 'product_images/scaled_1000325975.jpg', 1, '2025-05-01 12:40:04.089754', 10),
(39, 'product_images/scaled_1000325973.jpg', 0, '2025-05-01 12:40:04.093555', 10),
(40, 'product_images/scaled_1000325974.jpg', 0, '2025-05-01 12:40:04.098030', 10),
(41, 'product_images/scaled_1000325976.webp', 1, '2025-05-01 12:46:54.780008', 11),
(42, 'product_images/scaled_1000325977.webp', 0, '2025-05-01 12:46:54.782545', 11),
(43, 'product_images/scaled_1000325980.jpg', 1, '2025-05-01 12:57:31.296312', 12),
(44, 'product_images/scaled_1000325981.jpg', 0, '2025-05-01 12:57:31.299574', 12),
(45, 'product_images/scaled_1000325978.jpg', 0, '2025-05-01 12:57:31.302746', 12),
(46, 'product_images/scaled_1000325977_V4QLHV3.webp', 0, '2025-05-01 12:57:31.305227', 12),
(47, 'product_images/scaled_1000325984.jpg', 1, '2025-05-01 13:04:50.728575', 13),
(48, 'product_images/scaled_1000325983.jpg', 0, '2025-05-01 13:04:50.731156', 13),
(49, 'product_images/scaled_1000325982.jpg', 0, '2025-05-01 13:04:50.734190', 13),
(50, 'product_images/scaled_1000325987.jpg', 1, '2025-05-01 13:16:08.636170', 14),
(51, 'product_images/scaled_1000325986.jpg', 0, '2025-05-01 13:16:08.638427', 14),
(52, 'product_images/scaled_1000325985.jpg', 0, '2025-05-01 13:16:08.640593', 14),
(53, 'product_images/scaled_1000325990.jpg', 1, '2025-05-01 13:27:57.043463', 15),
(54, 'product_images/scaled_1000325991.jpg', 0, '2025-05-01 13:27:57.045534', 15),
(55, 'product_images/scaled_1000325989.jpg', 0, '2025-05-01 13:27:57.048231', 15),
(56, 'product_images/scaled_1000325993.jpg', 1, '2025-05-01 13:32:12.962803', 16),
(57, 'product_images/scaled_1000325992.jpg', 0, '2025-05-01 13:32:12.965215', 16);

-- --------------------------------------------------------

--
-- Table structure for table `products_productvariant`
--

CREATE TABLE `products_productvariant` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sku` varchar(100) NOT NULL,
  `price_modifier` decimal(10,2) NOT NULL,
  `stock_quantity` int(10) UNSIGNED NOT NULL CHECK (`stock_quantity` >= 0),
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `product_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products_subcategory`
--

CREATE TABLE `products_subcategory` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `image` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `category_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products_subcategory`
--

INSERT INTO `products_subcategory` (`id`, `name`, `slug`, `image`, `is_active`, `created_at`, `updated_at`, `category_id`) VALUES
(2, 'Front Bumper', 'front-bumper', '', 1, '2025-05-01 06:25:09.463832', '2025-05-01 06:25:29.394931', 2),
(3, 'Rear Bumper', 'rear-bumper', '', 1, '2025-05-01 06:25:58.637440', '2025-05-01 06:25:58.637475', 2),
(4, 'Headlights', 'headlights', '', 1, '2025-05-01 06:26:12.937836', '2025-05-01 06:26:12.937865', 3),
(5, 'Tail Lights', 'tail-lights', '', 1, '2025-05-01 06:26:28.513167', '2025-05-01 06:26:28.513377', 3),
(6, 'Fog Lights', 'fog-lights', '', 1, '2025-05-01 06:26:46.853059', '2025-05-01 06:26:46.853089', 3),
(7, 'Indicators', 'indicators', '', 1, '2025-05-01 06:27:02.235554', '2025-05-01 06:27:02.235599', 3),
(8, 'Side Mirrors', 'side-mirrors', '', 1, '2025-05-01 06:27:22.355607', '2025-05-01 06:27:22.355636', 4),
(9, 'Rear View Mirror', 'rear-view-mirror', '', 1, '2025-05-01 06:27:35.094746', '2025-05-01 06:27:35.094776', 4),
(10, 'Front Door', 'front-door', '', 1, '2025-05-01 06:27:51.532003', '2025-05-01 06:27:51.532034', 5),
(11, 'Rear Door', 'rear-door', '', 1, '2025-05-01 06:28:02.604788', '2025-05-01 06:28:02.604816', 5),
(12, 'Door Handles', 'door-handles', '', 1, '2025-05-01 06:28:15.436960', '2025-05-01 06:28:15.436989', 5),
(13, 'Windshield (Front & Rear)', 'windshield-front-rear', '', 1, '2025-05-01 06:28:33.505985', '2025-05-01 06:28:33.506013', 6),
(14, 'Side Window Glass', 'side-window-glass', '', 1, '2025-05-01 06:28:48.249738', '2025-05-01 06:28:48.249769', 6),
(15, 'Roof Rails', 'roof-rails', '', 1, '2025-05-01 06:30:04.978559', '2025-05-01 06:30:04.978588', 8),
(16, 'Side Panels', 'side-panels', '', 1, '2025-05-01 06:30:20.819548', '2025-05-01 06:30:20.819577', 8),
(17, 'Spoilers', 'spoilers', '', 1, '2025-05-01 06:30:39.843896', '2025-05-01 06:30:39.843940', 9),
(18, 'Mud Flaps', 'mud-flaps', '', 1, '2025-05-01 06:30:53.895868', '2025-05-01 06:30:53.895922', 9),
(19, 'Side Steps', 'side-steps', '', 1, '2025-05-01 06:31:07.229465', '2025-05-01 06:31:07.229491', 9),
(20, 'Shock Absorbers', 'shock-absorbers', '', 1, '2025-05-01 13:22:19.956874', '2025-05-01 13:22:19.956903', 10),
(21, 'Steering Rock', 'steering-rock', '', 1, '2025-05-01 13:22:50.009479', '2025-05-01 13:22:50.009509', 10);

-- --------------------------------------------------------

--
-- Table structure for table `settings_setting`
--

CREATE TABLE `settings_setting` (
  `id` bigint(20) NOT NULL,
  `key` varchar(100) NOT NULL,
  `value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`value`)),
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_manufacturer`
--

CREATE TABLE `users_manufacturer` (
  `id` bigint(20) NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `contact_name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `gst` varchar(50) NOT NULL,
  `address` longtext NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `website` varchar(200) DEFAULT NULL,
  `product_categories` longtext NOT NULL,
  `logo` varchar(200) DEFAULT NULL,
  `license` varchar(200) DEFAULT NULL,
  `terms_accepted` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users_manufacturer`
--

INSERT INTO `users_manufacturer` (`id`, `company_name`, `contact_name`, `phone`, `gst`, `address`, `city`, `state`, `country`, `website`, `product_categories`, `logo`, `license`, `terms_accepted`, `created_at`, `updated_at`, `user_id`) VALUES
(1, '4ttf', 'tyyyy', '1234567890', '09AAACH7409R1ZZ', 'tf', 'gf', 'gg', 'ggg', NULL, 'Auto Parts,Mechanical Parts', NULL, NULL, 1, '2025-05-01 05:27:52.522261', '2025-05-01 05:27:52.522315', 2),
(2, 'partzone', 'ashok shah', '9863574218', '27ABCDE1234F1Z5', 'c10 amul dram , shreenagar', 'jammu', 'kasmir', 'india', NULL, 'Auto Parts,Exterior Parts,Mechanical Parts', NULL, NULL, 1, '2025-05-01 06:43:31.412967', '2025-05-01 06:43:31.413190', 4),
(3, 'gearupmotors', 'veer shing', '9563412783', '07PQRSX5678L1Z3', 'shahpur , new market', 'ahemdabad', 'Gujarat', 'india', NULL, 'Auto Parts,Interior Parts,Body Parts,Mechanical Parts', NULL, NULL, 1, '2025-05-01 08:14:42.118608', '2025-05-01 08:15:25.139303', 5),
(4, 'speedycomponent', 'Mr.roy jah', '9568321470', '07PQRSX5678L1Z3', 'gokuldham,new trust', 'banglore', 'banglore', 'india', NULL, 'Auto Parts,Body Parts,Interior Parts,Mechanical Parts,Exterior Parts', NULL, NULL, 1, '2025-05-01 12:34:11.526086', '2025-05-01 12:34:11.526129', 6),
(5, 'motosparemart', 'David gain', '8965234710', '24WXYZA6789T1Z7', 'tech City,new beating society', 'hyderabad', 'hyderabad', 'india', NULL, 'Auto Parts,Mechanical Parts,Exterior Parts,Body Parts,Electronics', NULL, NULL, 1, '2025-05-01 13:13:24.013427', '2025-05-01 13:13:24.013460', 7);

-- --------------------------------------------------------

--
-- Table structure for table `users_shop`
--

CREATE TABLE `users_shop` (
  `id` bigint(20) NOT NULL,
  `shop_name` varchar(255) NOT NULL,
  `contact_name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `gst` varchar(50) NOT NULL,
  `address` longtext NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `website` varchar(200) DEFAULT NULL,
  `business_type` varchar(50) DEFAULT NULL,
  `logo` varchar(200) DEFAULT NULL,
  `license` varchar(200) DEFAULT NULL,
  `terms_accepted` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users_shop`
--

INSERT INTO `users_shop` (`id`, `shop_name`, `contact_name`, `phone`, `gst`, `address`, `city`, `state`, `country`, `website`, `business_type`, `logo`, `license`, `terms_accepted`, `created_at`, `updated_at`, `user_id`) VALUES
(1, 'biggspear', 'meet parmar', '9601361549', '09AAACH7409R1ZZ', 'c10 badrinarayn society near Madhav mall', 'ahemdabad', 'Gujarat', 'India', NULL, NULL, 'http://192.168.26.2:8000/media/logos/scaled_1000325037.jpg', NULL, 1, '2025-05-01 05:49:49.040672', '2025-05-01 05:49:49.040744', 3),
(2, 'sparehub', 'meet parmar', '9601361549', '33QWERT1234R1Z8', 'c10 badrinarayn society near Madhav mall', 'ahemdabad', 'Gujarat', 'india', NULL, NULL, 'http://192.168.26.2:8000/media/logos/scaled_1000325994.jpg', NULL, 1, '2025-05-01 13:39:51.548597', '2025-05-01 13:39:51.548627', 8),
(3, 'sparehome', 'MeetParmar', '9685231470', '33QWERT1234R1ZM', 'c 10 badrinarayn society near Madhav mall', 'Ahemdabad', 'Gujarat', 'India', NULL, NULL, 'http://192.168.26.2:8000/media/logos/scaled_1000325994_ojyHqjB.jpg', NULL, 1, '2025-05-01 13:42:52.840244', '2025-05-01 13:42:52.840270', 9);

-- --------------------------------------------------------

--
-- Table structure for table `users_user`
--

CREATE TABLE `users_user` (
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `id` int(11) NOT NULL,
  `username` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `role` varchar(20) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users_user`
--

INSERT INTO `users_user` (`password`, `last_login`, `is_superuser`, `id`, `username`, `email`, `role`, `is_active`, `is_staff`, `created_at`, `updated_at`) VALUES
('pbkdf2_sha256$870000$29fkxaIPgkea2ETB6n7r2Z$g+vwzn3wnsnskP3dqFlJ4SpBOgZ2U85iwewBwzcxfYk=', '2025-05-01 04:13:06.668964', 1, 1, 'admin', 'admin@gmail.com', '', 1, 1, '2025-05-01 04:11:45.836891', '2025-05-01 04:11:45.836934'),
('pbkdf2_sha256$870000$cx8l5HUYCkz56aoFEQ5knv$GwNBuvua/es5CALdPvAcw+vjiRulmbZBpe+/lfUnq9s=', NULL, 0, 2, 'm@gmail.com', 'm@gmail.com', 'manufacturer', 1, 0, '2025-05-01 05:27:52.401996', '2025-05-01 05:27:52.402122'),
('pbkdf2_sha256$870000$fpvkhrQgB2MuIzdkdG4AGB$NHMoIfhb47ybQVj6znT5DsWKXu3IQSEZVnR3WspzoGs=', NULL, 0, 3, 'mit@gmail.com', 'mit@gmail.com', 'shop', 1, 0, '2025-05-01 05:49:48.879432', '2025-05-01 05:49:48.879515'),
('pbkdf2_sha256$870000$RuHLGvbsZvVL7yI8gnr5iX$oRP+48pRA6w8v8uCmogKDTK4sjvgTOot/jBuByP7z5s=', NULL, 0, 4, 'autopartszone@gmail.com', 'autopartszone@gmail.com', 'manufacturer', 1, 0, '2025-05-01 06:43:31.362577', '2025-05-01 06:43:31.362821'),
('pbkdf2_sha256$870000$lEDhbhEvFcliQEN4lO0ALd$NaUMnipyRDrhhxrnOL2zFLEZCuQWhdwzSYWbYvtlS3I=', NULL, 0, 5, 'gearupmotors@outlook.com', 'gearupmotors@outlook.com', 'manufacturer', 1, 0, '2025-05-01 08:14:42.098438', '2025-05-01 08:15:25.121045'),
('pbkdf2_sha256$870000$axhIryVBBZolLl3wobJBLt$lUAeR1dffN9PWovl7Hai0U10RR+VK94Gbxp0bNODTwM=', NULL, 0, 6, 'speedycomponents@yahoo.com', 'speedycomponents@yahoo.com', 'manufacturer', 1, 0, '2025-05-01 12:34:11.512487', '2025-05-01 12:34:11.512537'),
('pbkdf2_sha256$870000$Q5AvtqLO1mCHBQRwpdPjoW$PHDC62nTEsucwZXY8ZRNF+MoasuBH/RmCXRHHC9uiBw=', NULL, 0, 7, 'motosparemart@techmail.com', 'motosparemart@techmail.com', 'manufacturer', 1, 0, '2025-05-01 13:13:24.003259', '2025-05-01 13:13:24.003292'),
('pbkdf2_sha256$870000$1QQX41t07nnAtshkziZpHh$ErF/epxixGHra3hHusZu6uCeEtCTxP5HwjiRdCk1UU4=', NULL, 0, 8, 'Meet@gmail.com', 'Meet@gmail.com', 'shop', 1, 0, '2025-05-01 13:39:51.536851', '2025-05-01 13:39:51.536884'),
('pbkdf2_sha256$870000$odJhNWd8JWOI0nr662j4cd$HpJL3NA38cbav3vO8D5CedBexmjIF201yaLUv6UnTLc=', NULL, 0, 9, 'meeet@gmail.com', 'meeet@gmail.com', 'shop', 1, 0, '2025-05-01 13:42:52.828928', '2025-05-01 13:42:52.828960');

-- --------------------------------------------------------

--
-- Table structure for table `users_user_groups`
--

CREATE TABLE `users_user_groups` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_user_user_permissions`
--

CREATE TABLE `users_user_user_permissions` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses_address`
--
ALTER TABLE `addresses_address`
  ADD PRIMARY KEY (`id`),
  ADD KEY `addresses_address_user_id_01a7dcfa_fk_users_user_id` (`user_id`);

--
-- Indexes for table `analytics_analytics`
--
ALTER TABLE `analytics_analytics`
  ADD PRIMARY KEY (`id`),
  ADD KEY `analytics_analytics_user_id_d88dd9cc_fk_users_user_id` (`user_id`);

--
-- Indexes for table `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indexes for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indexes for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_users_user_id` (`user_id`);

--
-- Indexes for table `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indexes for table `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indexes for table `notifications_notification`
--
ALTER TABLE `notifications_notification`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_notification_user_id_b5e8c0ff_fk_users_user_id` (`user_id`);

--
-- Indexes for table `orders_order`
--
ALTER TABLE `orders_order`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payment_id` (`payment_id`),
  ADD KEY `orders_order_user_id_e9b59eb1_fk_users_user_id` (`user_id`),
  ADD KEY `orders_order_billing_address_id_deb02e83_fk_orders_or` (`billing_address_id`),
  ADD KEY `orders_order_shipping_address_id_c4f8227a_fk_orders_or` (`shipping_address_id`);

--
-- Indexes for table `orders_orderaddress`
--
ALTER TABLE `orders_orderaddress`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders_orderpayment`
--
ALTER TABLE `orders_orderpayment`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders_orderstatusupdate`
--
ALTER TABLE `orders_orderstatusupdate`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders_order_status_updates`
--
ALTER TABLE `orders_order_status_updates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orders_order_status_upda_order_id_orderstatusupda_9d517cb2_uniq` (`order_id`,`orderstatusupdate_id`),
  ADD KEY `orders_order_status__orderstatusupdate_id_bed20be8_fk_orders_or` (`orderstatusupdate_id`);

--
-- Indexes for table `products_brand`
--
ALTER TABLE `products_brand`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `products_category`
--
ALTER TABLE `products_category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `products_product`
--
ALTER TABLE `products_product`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `products_product_subcategory_id_b28a1e3b_fk_products_` (`subcategory_id`),
  ADD KEY `products_product_brand_id_3e2e8fd1_fk_products_brand_id` (`brand_id`),
  ADD KEY `products_product_category_id_9b594869_fk_products_category_id` (`category_id`),
  ADD KEY `products_product_manufacturer_id_e20b1f1a_fk_users_user_id` (`manufacturer_id`);

--
-- Indexes for table `products_productimage`
--
ALTER TABLE `products_productimage`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_productimage_product_id_e747596a_fk_products_product_id` (`product_id`);

--
-- Indexes for table `products_productvariant`
--
ALTER TABLE `products_productvariant`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `products_productvari_product_id_d9c22902_fk_products_` (`product_id`);

--
-- Indexes for table `products_subcategory`
--
ALTER TABLE `products_subcategory`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `products_subcategory_category_id_name_3054145c_uniq` (`category_id`,`name`),
  ADD KEY `products_subcategory_slug_eaed3a95` (`slug`);

--
-- Indexes for table `settings_setting`
--
ALTER TABLE `settings_setting`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `settings_setting_user_id_key_0f31e60b_uniq` (`user_id`,`key`);

--
-- Indexes for table `users_manufacturer`
--
ALTER TABLE `users_manufacturer`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `users_shop`
--
ALTER TABLE `users_shop`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `users_user`
--
ALTER TABLE `users_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users_user_groups`
--
ALTER TABLE `users_user_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_user_groups_user_id_group_id_b88eab82_uniq` (`user_id`,`group_id`),
  ADD KEY `users_user_groups_group_id_9afc8d0e_fk_auth_group_id` (`group_id`);

--
-- Indexes for table `users_user_user_permissions`
--
ALTER TABLE `users_user_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_user_user_permissions_user_id_permission_id_43338c45_uniq` (`user_id`,`permission_id`),
  ADD KEY `users_user_user_perm_permission_id_0b93982e_fk_auth_perm` (`permission_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses_address`
--
ALTER TABLE `addresses_address`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `analytics_analytics`
--
ALTER TABLE `analytics_analytics`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT for table `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `notifications_notification`
--
ALTER TABLE `notifications_notification`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders_order`
--
ALTER TABLE `orders_order`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `orders_orderaddress`
--
ALTER TABLE `orders_orderaddress`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `orders_orderpayment`
--
ALTER TABLE `orders_orderpayment`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `orders_orderstatusupdate`
--
ALTER TABLE `orders_orderstatusupdate`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders_order_status_updates`
--
ALTER TABLE `orders_order_status_updates`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products_brand`
--
ALTER TABLE `products_brand`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `products_category`
--
ALTER TABLE `products_category`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `products_product`
--
ALTER TABLE `products_product`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `products_productimage`
--
ALTER TABLE `products_productimage`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `products_productvariant`
--
ALTER TABLE `products_productvariant`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products_subcategory`
--
ALTER TABLE `products_subcategory`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `settings_setting`
--
ALTER TABLE `settings_setting`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_manufacturer`
--
ALTER TABLE `users_manufacturer`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users_shop`
--
ALTER TABLE `users_shop`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users_user`
--
ALTER TABLE `users_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users_user_groups`
--
ALTER TABLE `users_user_groups`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_user_user_permissions`
--
ALTER TABLE `users_user_user_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses_address`
--
ALTER TABLE `addresses_address`
  ADD CONSTRAINT `addresses_address_user_id_01a7dcfa_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `analytics_analytics`
--
ALTER TABLE `analytics_analytics`
  ADD CONSTRAINT `analytics_analytics_user_id_d88dd9cc_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Constraints for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Constraints for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `notifications_notification`
--
ALTER TABLE `notifications_notification`
  ADD CONSTRAINT `notifications_notification_user_id_b5e8c0ff_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `orders_order`
--
ALTER TABLE `orders_order`
  ADD CONSTRAINT `orders_order_billing_address_id_deb02e83_fk_orders_or` FOREIGN KEY (`billing_address_id`) REFERENCES `orders_orderaddress` (`id`),
  ADD CONSTRAINT `orders_order_payment_id_46928ccc_fk_orders_orderpayment_id` FOREIGN KEY (`payment_id`) REFERENCES `orders_orderpayment` (`id`),
  ADD CONSTRAINT `orders_order_shipping_address_id_c4f8227a_fk_orders_or` FOREIGN KEY (`shipping_address_id`) REFERENCES `orders_orderaddress` (`id`),
  ADD CONSTRAINT `orders_order_user_id_e9b59eb1_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `orders_order_status_updates`
--
ALTER TABLE `orders_order_status_updates`
  ADD CONSTRAINT `orders_order_status__orderstatusupdate_id_bed20be8_fk_orders_or` FOREIGN KEY (`orderstatusupdate_id`) REFERENCES `orders_orderstatusupdate` (`id`),
  ADD CONSTRAINT `orders_order_status_updates_order_id_3ff9b45a_fk_orders_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders_order` (`id`);

--
-- Constraints for table `products_product`
--
ALTER TABLE `products_product`
  ADD CONSTRAINT `products_product_brand_id_3e2e8fd1_fk_products_brand_id` FOREIGN KEY (`brand_id`) REFERENCES `products_brand` (`id`),
  ADD CONSTRAINT `products_product_category_id_9b594869_fk_products_category_id` FOREIGN KEY (`category_id`) REFERENCES `products_category` (`id`),
  ADD CONSTRAINT `products_product_manufacturer_id_e20b1f1a_fk_users_user_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `users_user` (`id`),
  ADD CONSTRAINT `products_product_subcategory_id_b28a1e3b_fk_products_` FOREIGN KEY (`subcategory_id`) REFERENCES `products_subcategory` (`id`);

--
-- Constraints for table `products_productimage`
--
ALTER TABLE `products_productimage`
  ADD CONSTRAINT `products_productimage_product_id_e747596a_fk_products_product_id` FOREIGN KEY (`product_id`) REFERENCES `products_product` (`id`);

--
-- Constraints for table `products_productvariant`
--
ALTER TABLE `products_productvariant`
  ADD CONSTRAINT `products_productvari_product_id_d9c22902_fk_products_` FOREIGN KEY (`product_id`) REFERENCES `products_product` (`id`);

--
-- Constraints for table `products_subcategory`
--
ALTER TABLE `products_subcategory`
  ADD CONSTRAINT `products_subcategory_category_id_44d297b7_fk_products_` FOREIGN KEY (`category_id`) REFERENCES `products_category` (`id`);

--
-- Constraints for table `settings_setting`
--
ALTER TABLE `settings_setting`
  ADD CONSTRAINT `settings_setting_user_id_e8ffef46_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `users_manufacturer`
--
ALTER TABLE `users_manufacturer`
  ADD CONSTRAINT `users_manufacturer_user_id_e683b043_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `users_shop`
--
ALTER TABLE `users_shop`
  ADD CONSTRAINT `users_shop_user_id_f596b6f2_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `users_user_groups`
--
ALTER TABLE `users_user_groups`
  ADD CONSTRAINT `users_user_groups_group_id_9afc8d0e_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  ADD CONSTRAINT `users_user_groups_user_id_5f6f5a90_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);

--
-- Constraints for table `users_user_user_permissions`
--
ALTER TABLE `users_user_user_permissions`
  ADD CONSTRAINT `users_user_user_perm_permission_id_0b93982e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `users_user_user_permissions_user_id_20aca447_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
