import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import os
from config import get_tracks, get_albums, get_genres, get_artists, get_audio_features, get_streaming, get_track_artists

# ===== KONFIGURASI HALAMAN =====
st.set_page_config(page_title="Spotify Dashboard", page_icon="🎵", layout="wide")
st.title("🎵Visualisation of Spotify Track Database")

# ===== LOAD DATA DARI DATABASE =====
@st.cache_data
def load_data():
    """Load semua data dari database"""
    tracks = get_tracks()
    albums = get_albums()
    genres = get_genres()
    artists = get_artists()
    features = get_audio_features()
    streaming = get_streaming()
    track_artists = get_track_artists()
    
    # Ubah ke DataFrame
    df_tracks = pd.DataFrame(tracks, columns=["track_id", "track_name", "duration_ms", "album_name", "genre_name", "artist_count"])
    df_albums = pd.DataFrame(albums, columns=["album_id", "album_name", "release_date"])
    df_genres = pd.DataFrame(genres, columns=["genre_id", "genre_name"])
    df_artists = pd.DataFrame(artists, columns=["artist_id", "artist_name", "country_origin"])
    df_features = pd.DataFrame(features, columns=["track_id", "track_name", "danceability", "energy", "valence", "acousticness", "tempo", "loudness", "popularity"])
    df_streaming = pd.DataFrame(streaming, columns=["history_id", "track_id", "track_name", "user_id", "played_at", "duration_sec", "platform"])
    df_track_artists = pd.DataFrame(track_artists, columns=["track_id", "track_name", "artist_id", "artist_name", "is_main"])
    
    return df_tracks, df_albums, df_genres, df_artists, df_features, df_streaming, df_track_artists

# Load data
df_tracks, df_albums, df_genres, df_artists, df_features, df_streaming, df_track_artists = load_data()

# ===== MENU SIDEBAR =====
st.sidebar.title("📋 MENU")
pilihan = st.sidebar.radio("Pilih Halaman:", [
    "📊 Dashboard",
    "🎵 Data Lagu",
    "💿 Data Album",
    "🎼 Data Genre",
    "🎤 Data Artis",
    "🎚️ Audio Features",
    "▶️ Streaming History"
])

# ===== HALAMAN 1: DASHBOARD =====
if pilihan == "📊 Dashboard":
    st.subheader("📊 Ringkasan Data")
    
    # Tampilkan 4 metric
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("🎵 Total Lagu", len(df_tracks))
    col2.metric("💿 Total Album", len(df_albums))
    col3.metric("🎼 Total Genre", len(df_genres))
    col4.metric("🎤 Total Artis", len(df_artists))
    
    st.divider()
    
    # Chart 1: Lagu per Genre
    st.subheader("📈 Lagu per Genre")
    genre_counts = df_tracks['genre_name'].value_counts()
    fig1, ax1 = plt.subplots(figsize=(10, 5))
    genre_counts.plot(kind='barh', ax=ax1, color='#1DB954')
    ax1.set_xlabel("Jumlah Lagu")
    st.pyplot(fig1)
    
    # Chart 2: Top 10 Artis
    st.subheader("🎤 Top 10 Artis")
    artist_counts = df_track_artists['artist_name'].value_counts().head(10)
    fig2, ax2 = plt.subplots(figsize=(10, 5))
    artist_counts.plot(kind='barh', ax=ax2, color='#FF6B6B')
    ax2.set_xlabel("Jumlah Lagu")
    st.pyplot(fig2)
    
    # Chart 3: Durasi per Genre
    st.subheader("⏱️ Durasi Rata-rata per Genre")
    duration = df_tracks.groupby('genre_name')['duration_ms'].mean() / 60000
    fig3, ax3 = plt.subplots(figsize=(10, 5))
    duration.sort_values(ascending=False).plot(kind='bar', ax=ax3, color='#4ECDC4')
    ax3.set_ylabel("Durasi (Menit)")
    plt.xticks(rotation=45)
    st.pyplot(fig3)

# ===== HALAMAN 2: DATA LAGU =====
elif pilihan == "🎵 Data Lagu":
    st.subheader("🎵 Daftar Semua Lagu")
    st.metric("Total", len(df_tracks))
    
    # Cari lagu
    cari = st.text_input("🔍 Cari nama lagu:")
    if cari:
        hasil = df_tracks[df_tracks['track_name'].str.contains(cari, case=False, na=False)]
    else:
        hasil = df_tracks
    
    st.table(hasil)

# ===== HALAMAN 3: DATA ALBUM =====
elif pilihan == "💿 Data Album":
    st.subheader("💿 Daftar Semua Album")
    st.metric("Total", len(df_albums))
    st.table(df_albums)

# ===== HALAMAN 4: DATA GENRE =====
elif pilihan == "🎼 Data Genre":
    st.subheader("🎼 Daftar Semua Genre")
    st.metric("Total", len(df_genres))
    st.table(df_genres)

# ===== HALAMAN 5: DATA ARTIS =====
elif pilihan == "🎤 Data Artis":
    st.subheader("🎤 Daftar Semua Artis")
    st.metric("Total", len(df_artists))
    
    # Filter berdasarkan negara
    negara = st.multiselect("Filter Negara:", df_artists['country_origin'].unique())
    if negara:
        hasil = df_artists[df_artists['country_origin'].isin(negara)]
    else:
        hasil = df_artists
    
    st.table(hasil)

# ===== HALAMAN 6: AUDIO FEATURES =====
elif pilihan == "🎚️ Audio Features":
    st.subheader("🎚️ Karakteristik Audio Lagu")
    st.table(df_features)

# ===== HALAMAN 7: STREAMING HISTORY =====
elif pilihan == "▶️ Streaming History":
    st.subheader("▶️ Riwayat Streaming")
    st.metric("Total Streaming", len(df_streaming))
    st.table(df_streaming)

# ===== FOOTER DENGAN GENERATE DASHBOARD BUTTON =====
st.divider()
st.subheader("💾 Export Data & Visualisasi")

if st.button("📊 Generate dan Simpan Chart + CSV", use_container_width=True):
    st.info("Membuat visualisasi dan mengexport data...")
    
    os.makedirs('outputs', exist_ok=True)
    
    # Chart 1
    fig, ax = plt.subplots(figsize=(10, 5))
    genre_counts = df_tracks['genre_name'].value_counts()
    genre_counts.plot(kind='barh', ax=ax, color='#1DB954')
    ax.set_xlabel("Jumlah Lagu")
    ax.set_title("Lagu per Genre")
    plt.tight_layout()
    plt.savefig('outputs/01_tracks_per_genre.png', dpi=100)
    plt.close()
    
    # Chart 2
    fig, ax = plt.subplots(figsize=(10, 5))
    artist_counts = df_track_artists['artist_name'].value_counts().head(10)
    artist_counts.plot(kind='barh', ax=ax, color='#FF6B6B')
    ax.set_xlabel("Jumlah Lagu")
    ax.set_title("Top 10 Artis")
    plt.tight_layout()
    plt.savefig('outputs/02_top_10_artists.png', dpi=100)
    plt.close()
    
    # Chart 3
    fig, ax = plt.subplots(figsize=(10, 5))
    duration = df_tracks.groupby('genre_name')['duration_ms'].mean() / 60000
    duration.sort_values(ascending=False).plot(kind='bar', ax=ax, color='#4ECDC4')
    ax.set_ylabel("Durasi (Menit)")
    ax.set_title("Durasi Rata-rata per Genre")
    plt.tight_layout()
    plt.savefig('outputs/03_duration_per_genre.png', dpi=100)
    plt.close()
    
    # Export CSV
    df_tracks.to_csv('outputs/tracks_data.csv', index=False)
    df_albums.to_csv('outputs/albums_data.csv', index=False)
    df_genres.to_csv('outputs/genres_data.csv', index=False)
    df_artists.to_csv('outputs/artists_data.csv', index=False)
    df_features.to_csv('outputs/audio_features_data.csv', index=False)
    df_track_artists.to_csv('outputs/track_artist_bridge.csv', index=False)
    
    st.success("✅ Selesai! 3 chart PNG + 6 CSV file tersimpan di folder 'outputs/'")
    st.info("📁 Buka folder 'outputs' untuk melihat hasil")
