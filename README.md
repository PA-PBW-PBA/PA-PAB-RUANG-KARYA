<h1 align="center">Ruang Karya ✮</h2>

<p align="center"><em>Satu Ruang, Beragam Karya</em></p>

<p align="center">
  <img width="1672" height="941" alt="f9ed6bb2-455b-428a-8e72-25a2d1a6983b" src="https://github.com/user-attachments/assets/3652e2de-3b16-42f6-a49b-51da27b0728d" />

</p>

### Kelompok Alakadarnya

| **Nama**                         | **NIM**     | **Kelas**            |
|----------------------------------|------------|----------------------|
| Jen Agresia Misti                | 2409116007 | Sistem Informasi A   |
| Maifariza Aulia Dyas             | 2409116032 | Sistem Informasi A   |
| Yardan Raditya Rafi’ Widyadhana  | 2409116037 | Sistem Informasi A   |
| Rizqy                            | 2409116039 | Sistem Informasi A   |

## Deskripsi Aplikasi

Ruang Karya merupakan aplikasi yang dirancang untuk membantu aktivitas UKM Seni dan Kreativitas FEB Universitas Mulawarman. Aplikasi ini memudahkan pengurus untuk mengelola UKM serta membantu anggota mengakses berbagai informasi dalam satu sistem.

Dengan adanya Ruang Karya, aktivitas UKM yang sebelumnya masih manual kini dapat dikelola dengan lebih mudah.

---

## Fitur Aplikasi

### Pengunjung (Public)

- Melihat galeri kegiatan
- Melihat jumlah anggota dan divisi
- Melihat kegiatan terdekat UKM

### Anggota (User)

- Login ke dalam sistem
- Melihat kalender kegiatan (rapat, mentoring, event)
- Melihat galeri kegiatan
- Melihat data anggota
- Mengelola profil pribadi


### Admin

- Login ke dashboard admin
- Mengelola data anggota (CRUD)
- Mengelola absensi kegiatan
- Mengelola data keuangan kas
- Mengelola kegiatan melalui kalender
- Mengelola galeri kegiatan
- Melihat dashboard monitoring aktivitas UKM




---

## Struktur Folder

<details>
<summary>Struktur Folder Aplikasi Ruang Karya ★</summary>

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

### Table: `attendances`

| Column     | Type      | Description |
|------------|----------|-------------|
| id         | uuid     | Primary key absensi |
| event_id   | uuid     | ID event yang dihadiri |
| user_id    | uuid     | ID user yang hadir |
| status     | text     | Status kehadiran |
| created_by | uuid     | ID user yang mencatat absensi |
| created_at | timestamp | Waktu data dibuat |


### Table: `divisions`

| Column      | Type       | Description |
|------------|------------|-------------|
| id         | uuid       | Primary key divisi |
| name       | text       | Nama divisi |
| description| text       | Deskripsi divisi |
| color_hex  | text       | Kode warna divisi dalam format HEX |
| created_at | timestamp  | Waktu data divisi dibuat |

### Table: `event_divisions`

| Column      | Type | Description |
|------------|------|-------------|
| id         | uuid | Primary key relasi event dan divisi |
| event_id   | uuid | ID event |
| division_id| uuid | ID divisi |

### Table: `events`

| Column      | Type       | Description |
|------------|------------|-------------|
| id         | uuid       | Primary key event |
| title      | text       | Judul event |
| description| text       | Deskripsi event |
| location   | text       | Lokasi event |
| start_time | timestamp  | Waktu mulai event |
| end_time   | timestamp  | Waktu selesai event |
| created_by | uuid       | ID user pembuat event |
| created_at | timestamp  | Waktu event dibuat |
| updated_at | timestamp  | Waktu terakhir update event |
| is_public  | boolean    | Status apakah event bersifat publik |

### Table: `gallery`

| Column       | Type      | Description |
|--------------|----------|-------------|
| id           | uuid     | Primary key data galeri |
| division_id  | uuid     | ID divisi pemilik gambar |
| image_url    | text     | URL gambar |
| caption      | text     | Keterangan gambar |
| uploaded_by  | uuid     | ID user yang mengupload gambar |
| created_at   | timestamp| Waktu gambar diupload |

### Table: `kas`

| Column           | Type      | Description |
|------------------|----------|-------------|
| id               | uuid     | Primary key data kas |
| division_id      | uuid     | ID divisi terkait transaksi |
| type             | text     | Jenis transaksi (masuk / keluar) |
| amount           | numeric  | Jumlah uang |
| description      | text     | Keterangan transaksi |
| transaction_date | date     | Tanggal transaksi |
| created_by       | uuid     | ID user yang mencatat transaksi |
| created_at       | timestamp| Waktu data dibuat |

### Table: `member_divisions`

| Column      | Type      | Description |
|-------------|----------|-------------|
| id          | uuid     | Primary key data |
| user_id     | uuid     | ID user anggota |
| division_id | uuid     | ID divisi tempat user bergabung |
| created_at  | timestamp| Waktu data dibuat |


### Table: `profiles`

| Column         | Type       | Description |
|----------------|-----------|-------------|
| id             | uuid      | Primary key user |
| nim            | text      | Nomor induk mahasiswa |
| full_name      | text      | Nama lengkap user |
| email          | text      | Email user |
| phone          | text      | Nomor telepon user |
| angkatan       | text      | Tahun angkatan |
| avatar_url     | text      | URL foto profil |
| role           | text      | Peran user (admin atau anggota) |
| is_bendahara   | boolean   | Status apakah user bendahara |
| is_active      | boolean   | Status apakah user aktif |
| is_first_login | boolean   | Status login pertama |
| created_at     | timestamp | Waktu akun dibuat |
| updated_at     | timestamp | Waktu terakhir update data |


## Relasi Data

Semua data terhubung melalui relasi antar tabel menggunakan foreign key.

```

User (Supabase Auth)
        |
        v
    profiles
        |
        |
        +-------------------------+
        |                         |
        v                         v
member_divisions             attendances
   |      |                 |      |      |
   |      |                 |      |      |
   v      v                 v      v      v
profiles divisions      profiles  events  profiles
(user_id)(division_id)  (user_id)(event_id)(created_by)


events
   |
   |
   v
event_divisions
   |        |
   v        v
events   divisions


divisions
   |
   +-----------+-----------+
   |                       |
   v                       v
gallery                  kas
   |                       |
   v                       v
profiles                profiles
(uploaded_by)          (created_by)

```

---

## Widget yang Digunkan


| Kategori | Widget |
|----------|--------|
| Tampilan | `GetMaterialApp`, `Icon`, `Text`, `TextStyle`, `CircleAvatar`, `Image`, `CachedNetworkImage` |
| Layout | `Scaffold`, `SafeArea`, `CustomScrollView`, `SliverAppBar`, `FlexibleSpaceBar`, `SliverToBoxAdapter`, `Padding`, `Column`, `Container`, `Wrap`, `Row`, `Expanded`, `Flexible`, `AspectRatio`, `DraggableScrollableSheet`, `SliverFillRemaining`, `SliverPadding`, `SliverList`, `SliverGrid`, `SizedBox`, `Center`, `Stack`, `Positioned`, `GridView`, `ListView`, `ListView.separated`, `ClipRRect`, `IntrinsicHeight`, `SingleChildScrollView`, `Divider` |
| Interaksi | `TextButton`, `TextField`, `ElevatedButton`, `OutlinedButton.icon`, `ElevatedButton.icon`, `GestureDetector`, `InkWell`, `IconButton`, `FloatingActionButton.extended`, `FilterChip`, `PopupMenuButton`, `PopupMenuItem` |
| Animasi | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedCrossFade`, `BouncingScrollPhysics`, `NeverScrollableScrollPhysics`, `ScrollController`, `ScrollDirection`, `Shimmer.fromColors` |
| State | `StatefulWidget`, `State`, `StatelessWidget`, `Obx`, `GetxController`, `RxBool`, `RxString`, `RxList`, `RxMap`, `Rxn`, `RxInt` |
| Navigasi | `GetMaterialApp`, `GetPage`, `Get.back`, `Get.toNamed`, `Get.offAllNamed`, `Get.snackbar`, `Get.changeThemeMode`, `RouteSettings`, `GetMiddleware`, `showDialog`, `showModalBottomSheet` |
| Dependency | `BindingsBuilder`, `Get.lazyPut`, `Get.find`, `Get.put` |
| Form | `InputDecoration`, `OutlineInputBorder`, `TextEditingController` |
| Dialog | `AlertDialog`, `Dialog`, `showDatePicker`, `showTimePicker` |
| Media | `InteractiveViewer` |
| Kalender | `TableCalendar` |
| Visualisasi | `PieChart`, `PieChartData`, `PieChartSectionData` |
| Kontrol | `Visibility` |
| Styling | `BoxDecoration`, `Border`, `BorderRadius`, `BoxShadow`, `LinearGradient` |
| Loading | `CircularProgressIndicator`, `Shimmer.fromColors` |
| Inisialisasi | `WidgetsFlutterBinding` |

---


## Cara Menjalankan Aplikasi

Berikut langkah-langkah untuk menjalankan aplikasi Ruang Karya


1. Clone Repository
   
   > Clone project dari GitHub menggunakan perintah berikut:
   
   ```
   git clone https://github.com/PA-PBW-PBA/PA-PAB-RUANG-KARYA.git
   ```

2. Masuk ke folder project

   > Masuk ke direktori project yang telah di-clone:
   
   ```
   cd PA-PAB-RUANG-KARYA
   ```

4. Konfigurasi File Environment (.env)

   > Buat file .env di root project, kemudian isi dengan konfigurasi Supabase:
   
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

5. Install Dependencies

   > Install semua package yang dibutuhkan dengan perintah:

   ```
   flutter pub get
   ```

6. Jalankan Aplikasi

   > Jalankan aplikasi menggunakan perintah berikut:

   ```
   flutter run
   ```


