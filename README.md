<h1 align="center">Ruang Karya ✮</h2>

<p align="center"><em>Satu Ruang, Beragam Karya</em></p>

<p align="center">
  (GAMBAR)

</p>

### Kelompok Alakadarnya

| **Nama**                         | **NIM**     | **Kelas**            |
|----------------------------------|------------|----------------------|
| Jen Agresia Misti                | 2409116007 | Sistem Informasi A   |
| Maifariza Aulia Dyas             | 2409116032 | Sistem Informasi A   |
| Yardan Raditya Rafi’ Widyadhana  | 2409116037 | Sistem Informasi A   |
| Rizqy                            | 2409116039 | Sistem Informasi A   |

## Deskripsi Aplikasi

Ruang Karya merupakan sebuah aplikasi yang dirancang untuk membantu pengelolaan kegiatan dan anggota UKM Seni dan Kreativitas FEB. Aplikasi ini dibuat untuk mempermudah pengurus dalam mengelola data anggota, absensi, keuangan kas, serta pembagian tugas dalam satu sistem yang terpusat.

Melalui aplikasi ini, anggota UKM dapat melihat informasi kegiatan, melakukan absensi, serta mengakses galeri kegiatan. Selain itu, tersedia juga fitur kalender kegiatan yang membantu dalam melihat timeline kegiatan seperti rapat, mentoring, maupun event.

Untuk pengurus, aplikasi ini dilengkapi dengan fitur manajemen anggota (CRUD), pengelolaan kas, serta dashboard monitoring untuk memantau aktivitas UKM dengan lebih mudah. Dengan adanya sistem ini, UKM menjadi lebih terstruktur, rapi, dan efisien dibandingkan dengan cara manual.


---

## Struktur Folder

<details>

```
lib/
│   main.dart
│
├── app/
│   ├── controllers/
│   │   ├── attendance_controller.dart
│   │   ├── auth_controller.dart
│   │   ├── event_controller.dart
│   │   ├── gallery_controller.dart
│   │   ├── kas_controller.dart
│   │   ├── member_controller.dart
│   │   └── theme_controller.dart
│   │
│   ├── middlewares/
│   │   └── auth_middleware.dart
│   │
│   ├── models/
│   │   ├── attendance_model.dart
│   │   ├── division_model.dart
│   │   ├── event_model.dart
│   │   ├── gallery_model.dart
│   │   ├── kas_model.dart
│   │   └── user_model.dart
│   │
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   │
│   └── views/
│       ├── admin/
│       │   ├── attendance_input_page.dart
│       │   ├── dashboard_admin_page.dart
│       │   ├── event_form_page.dart
│       │   ├── event_list_page.dart
│       │   ├── gallery_admin_page.dart
│       │   ├── kas_form_page.dart
│       │   ├── kas_page.dart
│       │   ├── member_detail_page.dart
│       │   ├── member_form_page.dart
│       │   ├── member_list_page.dart
│       │   └── profile_admin_page.dart
│       │
│       ├── auth/
│       │   ├── change_password_page.dart
│       │   └── login_page.dart
│       │
│       ├── member/
│       │   ├── attendance_history_page.dart
│       │   ├── event_member_page.dart
│       │   ├── gallery_member_page.dart
│       │   ├── home_member_page.dart
│       │   ├── member_list_readonly_page.dart
│       │   └── profile_member_page.dart
│       │
│       ├── visitor/
│       │   ├── division_info_page.dart
│       │   ├── event_detail_page.dart
│       │   ├── event_visitor_page.dart
│       │   ├── gallery_visitor_page.dart
│       │   └── home_visitor_page.dart
│       │
│       └── widgets/
│           ├── admin_bottom_nav.dart
│           ├── division_badge.dart
│           ├── empty_state.dart
│           ├── event_card.dart
│           ├── event_detail_sheet.dart
│           ├── gallery_card.dart
│           ├── loading_skeleton.dart
│           ├── member_bottom_nav.dart
│           └── member_card.dart
│
└── core/
    ├── constants/
    │   └── app_constants.dart
    │
    └── theme/
        ├── app_colors.dart
        └── app_theme.dart

```
</details>

---

## Database Schema

---

## Fitur Aplikasi

### ᯓ★ Pengunjung (Public)

- Melihat informasi umum UKM
- Melihat galeri kegiatan
- Melihat jumlah anggota dan divisi
- Melihat kegiatan terdekat UKM

### ᯓ★ Anggota (User)

- Login ke dalam sistem
- Melihat kalender kegiatan (rapat, mentoring, event)
- Melihat galeri kegiatan
- Melihat data anggota
- Mengelola profil pribadi


### ᯓ★ Admin

- Login ke dashboard admin
- Mengelola data anggota (CRUD)
- Mengelola absensi kegiatan
- Mengelola data keuangan kas
- Mengelola kegiatan melalui kalender
- Mengelola galeri kegiatan
- Melihat dashboard monitoring aktivitas UKM


---


## Widget yang Digunkan
