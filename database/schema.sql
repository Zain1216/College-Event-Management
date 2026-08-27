-- ============================================================================
-- FusionFiesta - College Event Information & Management System
-- TechWiz 6 - Aptech Global Tech Competition
-- Database Schema & Reference Definition
-- ============================================================================

CREATE DATABASE IF NOT EXISTS fusion_fiesta;
USE fusion_fiesta;

-- ----------------------------------------------------------------------------
-- Table: users
-- Core authentication and user profile table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(64) PRIMARY KEY,
    email VARCHAR(191) NOT NULL UNIQUE,
    full_name VARCHAR(128) NOT NULL,
    role ENUM('visitor', 'participant', 'organizer', 'admin') NOT NULL DEFAULT 'visitor',
    department VARCHAR(128) NOT NULL DEFAULT 'General',
    mobile VARCHAR(32) DEFAULT '',
    enrollment_no VARCHAR(64) NULL,
    college_id_proof VARCHAR(512) NULL,
    profile_pic_url VARCHAR(512) NULL,
    is_approved BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_role (role),
    INDEX idx_user_department (department)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: events
-- Central college event information table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS events (
    event_id VARCHAR(64) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category ENUM('Technical', 'Cultural', 'Sports', 'Seminar', 'Workshop') NOT NULL,
    department VARCHAR(128) NOT NULL,
    event_date DATETIME NOT NULL,
    event_time VARCHAR(64) NOT NULL,
    venue VARCHAR(191) NOT NULL,
    latitude DECIMAL(10, 8) DEFAULT 12.9716,
    longitude DECIMAL(11, 8) DEFAULT 77.5946,
    status ENUM('pending', 'approved', 'live', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    organizer_id VARCHAR(64) NOT NULL,
    organizer_name VARCHAR(128) NOT NULL,
    organizer_email VARCHAR(191) DEFAULT '',
    organizer_phone VARCHAR(32) DEFAULT '',
    max_participants INT NOT NULL DEFAULT 100,
    registered_count INT NOT NULL DEFAULT 0,
    banner_url VARCHAR(512) NOT NULL,
    guidelines_pdf_url VARCHAR(512) NULL,
    average_rating DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    review_count INT NOT NULL DEFAULT 0,
    is_top_rated BOOLEAN NOT NULL DEFAULT FALSE,
    certificate_fee DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    rejection_reason TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organizer_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_event_category (category),
    INDEX idx_event_status (status),
    INDEX idx_event_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: registrations
-- Event registration & digital QR entry pass
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS registrations (
    registration_id VARCHAR(64) PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    student_id VARCHAR(64) NOT NULL,
    student_name VARCHAR(128) NOT NULL,
    student_email VARCHAR(191) NOT NULL,
    enrollment_no VARCHAR(64) NOT NULL,
    department VARCHAR(128) NOT NULL,
    registered_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('registered', 'attended', 'cancelled') NOT NULL DEFAULT 'registered',
    qr_pass_code VARCHAR(191) NOT NULL UNIQUE,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_reg_event (event_id),
    INDEX idx_reg_student (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: attendance
-- Live attendance & QR scan verification logs
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id VARCHAR(64) PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    student_id VARCHAR(64) NOT NULL,
    student_name VARCHAR(128) NOT NULL,
    enrollment_no VARCHAR(64) DEFAULT '',
    department VARCHAR(128) DEFAULT '',
    attended BOOLEAN NOT NULL DEFAULT TRUE,
    marked_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_in_method ENUM('qr_scanner', 'manual') NOT NULL DEFAULT 'qr_scanner',
    verified_by VARCHAR(64) NOT NULL,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_att_event (event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: feedback
-- 4-Parameter event feedback and ratings
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS feedback (
    feedback_id VARCHAR(64) PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    event_title VARCHAR(255) NOT NULL,
    student_id VARCHAR(64) NOT NULL,
    student_name VARCHAR(128) NOT NULL,
    organization_rating INT NOT NULL CHECK (organization_rating BETWEEN 1 AND 5),
    relevance_rating INT NOT NULL CHECK (relevance_rating BETWEEN 1 AND 5),
    coordination_rating INT NOT NULL CHECK (coordination_rating BETWEEN 1 AND 5),
    overall_rating INT NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    average_score DECIMAL(3, 2) NOT NULL,
    comments TEXT NULL,
    is_flagged BOOLEAN NOT NULL DEFAULT FALSE,
    submitted_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_fb_event (event_id),
    INDEX idx_fb_flagged (is_flagged)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: certificates
-- Issued participation and winner e-certificates with fee status
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS certificates (
    certificate_id VARCHAR(64) PRIMARY KEY,
    certificate_number VARCHAR(128) NOT NULL UNIQUE,
    event_id VARCHAR(64) NOT NULL,
    event_title VARCHAR(255) NOT NULL,
    event_category VARCHAR(64) NOT NULL DEFAULT 'Technical',
    event_date DATETIME NOT NULL,
    student_id VARCHAR(64) NOT NULL,
    student_name VARCHAR(128) NOT NULL,
    enrollment_no VARCHAR(64) NOT NULL,
    department VARCHAR(128) NOT NULL,
    certificate_type ENUM('participation', 'winnerFirst', 'winnerSecond', 'winnerThird', 'specialAppreciation') NOT NULL DEFAULT 'participation',
    fee_amount DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    is_fee_paid BOOLEAN NOT NULL DEFAULT FALSE,
    transaction_id VARCHAR(128) NULL,
    paid_on DATETIME NULL,
    issued_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    certificate_pdf_url VARCHAR(512) NULL,
    verification_qr_data VARCHAR(512) NOT NULL,
    issued_by_organizer VARCHAR(128) NOT NULL DEFAULT 'Event Committee',
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_cert_student (student_id),
    INDEX idx_cert_number (certificate_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: media_gallery
-- Campus event photos and video clips
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS media_gallery (
    media_id VARCHAR(64) PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    event_title VARCHAR(255) NOT NULL,
    media_type ENUM('image', 'video') NOT NULL DEFAULT 'image',
    media_url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512) NULL,
    caption VARCHAR(255) NOT NULL,
    category VARCHAR(64) NOT NULL,
    department VARCHAR(128) NOT NULL,
    uploaded_by VARCHAR(64) NOT NULL,
    uploader_name VARCHAR(128) NOT NULL,
    is_approved BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    likes_count INT NOT NULL DEFAULT 0,
    uploaded_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: notifications
-- Real-time in-app alerts and broadcast announcements
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
    notification_id VARCHAR(64) PRIMARY KEY,
    recipient_id VARCHAR(64) NOT NULL,
    recipient_role VARCHAR(64) NOT NULL DEFAULT 'all',
    title VARCHAR(191) NOT NULL,
    message TEXT NOT NULL,
    event_id VARCHAR(64) NULL,
    notification_type VARCHAR(64) NOT NULL DEFAULT 'general',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_notif_recipient (recipient_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- Table: contact_queries
-- Support messages and admin replies
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS contact_queries (
    query_id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    email VARCHAR(191) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    category VARCHAR(64) NOT NULL DEFAULT 'General',
    message TEXT NOT NULL,
    is_resolved BOOLEAN NOT NULL DEFAULT FALSE,
    admin_reply TEXT NULL,
    submitted_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- SEED DATA FOR TESTING & EVALUATION
-- ============================================================================

INSERT INTO users (user_id, email, full_name, role, department, mobile, enrollment_no, is_approved, is_active) VALUES
('usr_admin_01', 'admin@fusionfiesta.edu', 'Dr. Arthur Vance', 'admin', 'Dean Academic Affairs', '+1 (555) 019-2834', NULL, TRUE, TRUE),
('usr_org_01', 'organizer@fusionfiesta.edu', 'Prof. Elena Rostova', 'organizer', 'Computer Science & Engineering', '+1 (555) 382-9102', NULL, TRUE, TRUE),
('usr_org_02', 'sports.head@fusionfiesta.edu', 'Coach Marcus Thorne', 'organizer', 'Physical Education', '+1 (555) 749-2847', NULL, TRUE, TRUE),
('usr_student_01', 'student@fusionfiesta.edu', 'Zain Ahmed', 'participant', 'Computer Science & Engineering', '+1 (555) 912-4029', 'CS-2023-089', TRUE, TRUE),
('usr_student_02', 'sarah.connor@fusionfiesta.edu', 'Sarah Connor', 'participant', 'Information Technology', '+1 (555) 674-8833', 'IT-2024-042', TRUE, TRUE),
('usr_visitor_01', 'visitor@fusionfiesta.edu', 'Rohan Verma', 'visitor', 'Mechanical Engineering', '+1 (555) 441-2098', NULL, TRUE, TRUE);

INSERT INTO events (event_id, title, description, category, department, event_date, event_time, venue, status, organizer_id, organizer_name, organizer_email, max_participants, registered_count, banner_url, is_top_rated, certificate_fee) VALUES
('evt_technova_01', 'TechNova 2026: 36-Hour Hackathon', 'Premier annual 36-hour inter-college hackathon focusing on AI solutions and Cloud Architectures.', 'Technical', 'Computer Science & Engineering', '2026-09-15 09:00:00', '09:00 AM - 09:00 PM', 'Innovation Hub (Hall B)', 'live', 'usr_org_01', 'Prof. Elena Rostova', 'organizer@fusionfiesta.edu', 150, 132, 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=1200', TRUE, 50.00),
('evt_euphoria_02', 'Euphoria 2026: Battle of the College Bands', 'Grand musical night showcasing acoustic, rock, and fusion college bands with professional audio-visual stage production.', 'Cultural', 'Fine Arts & Music Society', '2026-09-22 17:30:00', '05:30 PM - 10:30 PM', 'Open Air Amphitheatre', 'approved', 'usr_org_01', 'Prof. Elena Rostova', 'organizer@fusionfiesta.edu', 400, 285, 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=1200', TRUE, 40.00),
('evt_roboclash_03', 'RoboClash: 15kg Combat Robot Arena', 'High-octane robotics battle tournament featuring customized combat bots in bulletproof arena.', 'Technical', 'Mechanical & Robotics', '2026-09-28 11:00:00', '11:00 AM - 04:00 PM', 'Mechanical Workshops Arena', 'approved', 'usr_org_01', 'Prof. Elena Rostova', 'organizer@fusionfiesta.edu', 80, 64, 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=1200', FALSE, 50.00),
('evt_bball_04', 'Inter-University 3x3 Basketball Slam', 'Fast-paced FIBA rules 3x3 basketball championship with men and women brackets.', 'Sports', 'Physical Education', '2026-10-05 08:30:00', '08:30 AM - 06:00 PM', 'Indoor Sports Complex', 'approved', 'usr_org_02', 'Coach Marcus Thorne', 'sports.head@fusionfiesta.edu', 64, 48, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200', TRUE, 30.00),
('evt_flutter_ws_06', 'Hands-on Masterclass: Cross-Platform Flutter & Firebase', 'Practical workshop covering reactive state management, Firestore live streams, and offline cache.', 'Workshop', 'Computer Science & Engineering', '2026-08-20 10:00:00', '10:00 AM - 04:00 PM', 'Computer Lab 4 (Block C)', 'completed', 'usr_org_01', 'Prof. Elena Rostova', 'organizer@fusionfiesta.edu', 60, 60, 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=1200', TRUE, 50.00);

INSERT INTO registrations (registration_id, event_id, student_id, student_name, student_email, enrollment_no, department, registered_on, status, qr_pass_code) VALUES
('reg_technova_01', 'evt_technova_01', 'usr_student_01', 'Zain Ahmed', 'student@fusionfiesta.edu', 'CS-2023-089', 'Computer Science & Engineering', '2026-08-03 10:15:00', 'registered', 'PASS-TECHNOVA-CS2023089-ZAIN'),
('reg_flutter_02', 'evt_flutter_ws_06', 'usr_student_01', 'Zain Ahmed', 'student@fusionfiesta.edu', 'CS-2023-089', 'Computer Science & Engineering', '2026-08-01 14:20:00', 'attended', 'PASS-FLUTTER-CS2023089-ZAIN');

INSERT INTO certificates (certificate_id, certificate_number, event_id, event_title, event_category, event_date, student_id, student_name, enrollment_no, department, certificate_type, fee_amount, is_fee_paid, transaction_id, verification_qr_data, issued_by_organizer) VALUES
('cert_flutter_01', 'FF-2026-CS-0042', 'evt_flutter_ws_06', 'Hands-on Masterclass: Cross-Platform Flutter & Firebase', 'Workshop', '2026-08-20 10:00:00', 'usr_student_01', 'Zain Ahmed', 'CS-2023-089', 'Computer Science & Engineering', 'winnerFirst', 50.00, TRUE, 'TXN_CYBERPAY_94827163', 'VERIFY-FF-2026-CS-0042-ZAIN-AHMED-1ST-PLACE', 'Prof. Elena Rostova');
