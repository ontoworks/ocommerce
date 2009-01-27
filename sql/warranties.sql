-- phpMyAdmin SQL Dump
-- version 2.9.1.1-Debian-3
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: May 01, 2008 at 05:34 AM
-- Server version: 5.0.30
-- PHP Version: 5.2.0-8+etch5~pu1
-- 
-- Database: `tpd_development`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `warranties`
-- 

CREATE TABLE IF NOT EXISTS `warranties` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `context` varchar(255) default NULL,
  `product_id` int(11) default NULL,
  `category_id` int(11) default NULL,
  `price` decimal(8,2) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=85 ;

-- 
-- Dumping data for table `warranties`
-- 

INSERT INTO `warranties` (`id`, `title`, `context`, `product_id`, `category_id`, `price`, `created_at`, `updated_at`) VALUES 
(67, '1 Year Extended Warranty', 'default', NULL, NULL, 39.00, '2008-03-27 18:22:12', '2008-04-28 18:23:06'),
(68, '2 Year Extended Warranty', 'default', NULL, NULL, 59.00, '2008-03-27 18:22:27', '2008-04-28 18:23:08'),
(69, '3 Year Extended Warranty', 'default', NULL, NULL, 99.00, '2008-03-27 18:22:41', '2008-04-28 18:23:11'),
(70, '1 Year Extended Warranty', 'default', NULL, NULL, 79.00, '2008-03-27 18:25:31', '2008-04-28 18:23:35'),
(71, '2 Year Extended Warranty', 'default', NULL, NULL, 129.00, '2008-03-27 18:25:48', '2008-04-28 18:24:58'),
(72, '3 Year Extended Warranty', 'default', NULL, NULL, 199.00, '2008-03-27 18:26:13', '2008-04-28 18:25:01'),
(73, '3 Year Extended Warranty', 'default', NULL, NULL, 299.00, '2008-03-27 18:29:24', '2008-04-28 18:27:34'),
(74, '2 Year Extended Warranty', 'default', NULL, NULL, 229.00, '2008-03-27 18:29:27', '2008-04-28 18:25:26'),
(75, '1 Year Extended Warranty', 'default', NULL, NULL, 149.00, '2008-03-27 18:29:29', '2008-04-28 18:27:32'),
(76, '2 year - $189.0000 - Old TPD', 'old', NULL, NULL, 189.00, NULL, NULL),
(77, '1 year - $49.0000 - Old TPD', 'old', NULL, NULL, 49.00, NULL, NULL),
(78, '3 year - $279.0000 - Old TPD', 'old', NULL, NULL, 279.00, NULL, NULL),
(79, '3 year - $129.0000 - Old TPD', 'old', NULL, NULL, 129.00, NULL, NULL),
(80, '1 year - $99.0000 - Old TPD', 'old', NULL, NULL, 99.00, NULL, NULL),
(81, '2 year - $89.0000 - Old TPD', 'old', NULL, NULL, 89.00, NULL, NULL),
(82, '1 year - $199.0000 - Old TPD', 'old', NULL, NULL, 199.00, NULL, NULL),
(83, '2 year - $289.0000 - Old TPD', 'old', NULL, NULL, 289.00, NULL, NULL),
(84, '3 year - $379.0000 - Old TPD', 'old', NULL, NULL, 379.00, NULL, NULL);
