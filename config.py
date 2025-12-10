import mysql.connector

# Koneksi ke database Spotify
db = mysql.connector.connect(
    host="127.0.0.1",
    port="3306",
    user="root",
    password="",
    database="db_spotify_track"
)

cursor = db.cursor()

# Fungsi ambil semua data lagu
def get_tracks():
    """Ambil semua data lagu dengan album, genre, artis, dan jumlah artis"""
    cursor.execute('''
        SELECT 
            t.track_internal_id,
            t.track_name,
            t.duration_ms,
            al.album_name,
            g.genre_name,
            GROUP_CONCAT(DISTINCT a.artist_name SEPARATOR ', ') as artist_names,
            COUNT(DISTINCT tab.artist_id) as artist_count
        FROM Tracks t
        JOIN Albums al ON t.album_id = al.album_id
        JOIN Genres g ON t.genre_id = g.genre_id
        LEFT JOIN Track_Artist_Bridge tab ON t.track_internal_id = tab.track_internal_id
        LEFT JOIN Artists a ON tab.artist_id = a.artist_id
        GROUP BY t.track_internal_id, t.track_name, t.duration_ms, al.album_name, g.genre_name
        ORDER BY t.track_internal_id ASC
    ''')
    return cursor.fetchall()

# Fungsi ambil data album
def get_albums():
    """Ambil semua data album"""
    cursor.execute('SELECT album_id, album_name, release_date FROM Albums ORDER BY album_id ASC')
    return cursor.fetchall()

# Fungsi ambil data genre
def get_genres():
    """Ambil semua data genre"""
    cursor.execute('SELECT genre_id, genre_name FROM Genres ORDER BY genre_id ASC')
    return cursor.fetchall()

# Fungsi ambil data artis
def get_artists():
    """Ambil semua data artis beserta negara asal"""
    cursor.execute('SELECT artist_id, artist_name, country_origin FROM Artists ORDER BY artist_id ASC')
    return cursor.fetchall()

# Fungsi ambil audio features
def get_audio_features():
    """Ambil data karakteristik audio setiap lagu"""
    cursor.execute('''
        SELECT 
            taf.track_internal_id,
            t.track_name,
            taf.danceability,
            taf.energy,
            taf.valence,
            taf.acousticness,
            taf.tempo,
            taf.loudness,
            taf.popularity_snapshot
        FROM Track_Audio_Features taf
        JOIN Tracks t ON taf.track_internal_id = t.track_internal_id
        ORDER BY taf.track_internal_id ASC
    ''')
    return cursor.fetchall()

# Fungsi ambil streaming history
def get_streaming():
    """Ambil data riwayat streaming/pemutaran lagu"""
    cursor.execute('''
        SELECT 
            sh.history_id,
            sh.track_internal_id,
            t.track_name,
            sh.user_id,
            u.gender,
            u.region_code,
            u.age_group,
            sh.played_at,
            sh.play_duration_sec,
            sh.platform
        FROM Streaming_History sh
        JOIN Tracks t ON sh.track_internal_id = t.track_internal_id
        JOIN Users u ON sh.user_id = u.user_id
        ORDER BY sh.played_at DESC
    ''')
    return cursor.fetchall()

# Fungsi ambil track-artist bridge
def get_track_artists():
    """Ambil hubungan antara lagu dan artis"""
    cursor.execute('''
        SELECT 
            tab.track_internal_id,
            t.track_name,
            tab.artist_id,
            a.artist_name,
            tab.is_main_artist
        FROM Track_Artist_Bridge tab
        JOIN Tracks t ON tab.track_internal_id = t.track_internal_id
        JOIN Artists a ON tab.artist_id = a.artist_id
        ORDER BY tab.track_internal_id ASC
    ''')
    return cursor.fetchall()
