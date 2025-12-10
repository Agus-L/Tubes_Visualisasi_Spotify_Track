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
    df_tracks = pd.DataFrame(tracks, columns=["track_id", "track_name", "duration_ms", "album_name", "genre_name", "artist_names", "artist_count"])
    df_albums = pd.DataFrame(albums, columns=["album_id", "album_name", "release_date"])
    df_genres = pd.DataFrame(genres, columns=["genre_id", "genre_name"])

    df_artists = pd.DataFrame(artists, columns=["artist_id", "artist_name", "country_origin"])
    df_features = pd.DataFrame(features, columns=["track_id", "track_name", "danceability", "energy", "valence", "acousticness", "tempo", "loudness", "popularity"])
    df_streaming = pd.DataFrame(streaming, columns=["history_id", "track_id", "track_name", "user_id", "gender", "region_code", "age_group", "played_at", "duration_sec", "platform"])
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
    
    st.divider()
    
    # Filter kolom yang ditampilkan
    display_columns = st.multiselect(
        "📋 Pilih Kolom yang Ditampilkan:",
        ["track_name", "duration_ms", "album_name", "genre_name", "artist_names", "artist_count"],
        default=["track_name", "album_name", "genre_name", "artist_names"]
    )
    
    if display_columns:
        df_display = hasil[display_columns].copy()
        if 'duration_ms' in df_display.columns:
            df_display['duration_ms'] = (df_display['duration_ms'] / 60000).round(2).astype(str) + ' min'
        st.dataframe(df_display, use_container_width=True, hide_index=True)

# ===== HALAMAN 3: DATA ALBUM =====
elif pilihan == "💿 Data Album":
    st.subheader("💿 Daftar Semua Album")
    st.metric("Total", len(df_albums))
    
    st.divider()
    
    # Filter kolom yang ditampilkan
    display_columns = st.multiselect(
        "📋 Pilih Kolom yang Ditampilkan:",
        ["album_name", "release_date"],
        default=["album_name", "release_date"]
    )
    
    if display_columns:
        df_display = df_albums[display_columns].copy()
        st.dataframe(df_display, use_container_width=True, hide_index=True)

# ===== HALAMAN 4: DATA GENRE =====
elif pilihan == "🎼 Data Genre":
    st.subheader("🎼 Daftar Semua Genre")
    st.metric("Total", len(df_genres))
    
    st.divider()
    
    # Filter kolom yang ditampilkan
    display_columns = st.multiselect(
        "📋 Pilih Kolom yang Ditampilkan:",
        ["genre_id", "genre_name"],
        default=["genre_name"]
    )
    
    if display_columns:
        df_display = df_genres[display_columns].copy()
        st.dataframe(df_display, use_container_width=True, hide_index=True)

# ===== HALAMAN 5: DATA ARTIS =====
elif pilihan == "🎤 Data Artis":
    st.subheader("🎤 Daftar Semua Artis")
    st.metric("Total", len(df_artists))
    
    st.divider()
    
    # Filter kolom yang ditampilkan
    display_columns = st.multiselect(
        "📋 Pilih Kolom yang Ditampilkan:",
        ["artist_id", "artist_name", "country_origin"],
        default=["artist_name", "country_origin"]
    )
    
    if display_columns:
        df_display = df_artists[display_columns].copy()
        st.dataframe(df_display, use_container_width=True, hide_index=True)

# ===== HALAMAN 6: AUDIO FEATURES =====
elif pilihan == "🎚️ Audio Features":
    st.subheader("🎚️ Karakteristik Audio Lagu")
    
    st.divider()
    
    # Filter kolom yang ditampilkan
    display_columns = st.multiselect(
        "📋 Pilih Kolom yang Ditampilkan:",
        ["track_name", "danceability", "energy", "valence", "acousticness", "tempo", "loudness", "popularity"],
        default=["track_name", "danceability", "energy", "tempo", "popularity"]
    )
    
    if display_columns:
        df_display = df_features[display_columns].copy()
        st.dataframe(df_display, use_container_width=True, hide_index=True)

# ===== HALAMAN 7: STREAMING HISTORY =====
elif pilihan == "▶️ Streaming History":
    st.subheader("▶️ Riwayat Streaming Pengguna")
    
    # Tampilkan 3 metric
    col1, col2, col3 = st.columns(3)
    col1.metric("📊 Total Streaming", len(df_streaming))
    col2.metric("👥 Unique Users", df_streaming['user_id'].nunique())
    col3.metric("🎵 Unique Tracks", df_streaming['track_id'].nunique())
    
    st.divider()
    
    # Tampilkan data dengan kolom yang dipilih
    display_columns = st.multiselect(
        "📋 Pilih Kolom yang Ditampilkan:",
        ["track_name", "user_id", "gender", "region_code", "age_group", "played_at", "duration_sec", "platform"],
        default=["track_name", "gender", "region_code", "platform", "played_at"]
    )
    
    if display_columns:
        st.subheader("📊 Data Streaming")
        
        # Format tampilan yang lebih readable
        df_display = df_streaming[display_columns].copy()
        
        # Format kolom jika ada
        if 'played_at' in df_display.columns:
            df_display['played_at'] = pd.to_datetime(df_display['played_at']).dt.strftime('%Y-%m-%d %H:%M:%S')
        
        if 'duration_sec' in df_display.columns:
            df_display['duration_sec'] = df_display['duration_sec'].astype('int64').astype(str) + ' sec'
        
        # Tampilkan dengan pagination
        st.dataframe(df_display, use_container_width=True, hide_index=True)
    
    st.divider()
    
    # Analisis Tambahan
    st.subheader("📈 Analisis Streaming")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.write("**Streaming by Gender**")
        gender_dist = df_streaming['gender'].value_counts()
        fig, ax = plt.subplots(figsize=(8, 4))
        gender_dist.plot(kind='bar', ax=ax, color='#1DB954')
        ax.set_xlabel("Gender")
        ax.set_ylabel("Jumlah Streaming")
        plt.xticks(rotation=0)
        st.pyplot(fig)
    
    with col2:
        st.write("**Streaming by Region**")
        region_dist = df_streaming['region_code'].value_counts().head(10)
        fig, ax = plt.subplots(figsize=(8, 4))
        region_dist.plot(kind='barh', ax=ax, color='#FF6B6B')
        ax.set_xlabel("Jumlah Streaming")
        st.pyplot(fig)
    
    st.divider()