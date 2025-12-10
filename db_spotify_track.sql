SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Streaming_History;
DROP TABLE IF EXISTS Track_Artist_Bridge;
DROP TABLE IF EXISTS Track_Audio_Features;
DROP TABLE IF EXISTS Tracks;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Artists;
DROP TABLE IF EXISTS Albums;
DROP TABLE IF EXISTS Genres;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- =============================================================

--Relasi zero to many
--Tabel-tabel ini bisa berdiri sendiri tanpa anak.
CREATE TABLE Genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE,
    parent_genre_id INT
);

CREATE TABLE Albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    release_date DATE
);

CREATE TABLE Users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_anon_token VARCHAR(36) NOT NULL UNIQUE,
    region_code CHAR(2),
    age_group VARCHAR(20),
    gender CHAR(1)
);

CREATE TABLE Artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL UNIQUE,
    country_origin CHAR(2)
);

CREATE TABLE Tracks (
    track_internal_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    track_spotify_id VARCHAR(50) NOT NULL UNIQUE,
    track_name VARCHAR(255) NOT NULL,
    duration_ms INT,
    is_explicit BOOLEAN DEFAULT FALSE,   
    album_id INT NOT NULL,  -- Albums ke Tracks (Zero to Many , tapi FK di sini)
    genre_id INT NOT NULL, --  Genres ke Tracks (Zero to Many secara logika bisnis, tapi FK di sini)
    CONSTRAINT fk_track_album FOREIGN KEY (album_id) REFERENCES Albums(album_id),
    CONSTRAINT fk_track_genre FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);

--One to Many : Tracks ke Track_Audio_Features
--Satu Track punya Satu Fitur Audio (1-to-1 implementation of 1-to-many logic)
CREATE TABLE Track_Audio_Features (
    track_internal_id BIGINT PRIMARY KEY,
    danceability DECIMAL(5,4),
    energy DECIMAL(5,4),
    valence DECIMAL(5,4),
    acousticness DECIMAL(5,4),
    instrumentalness DECIMAL(9,8),
    liveness DECIMAL(5,4),
    speechiness DECIMAL(5,4),
    tempo FLOAT,
    loudness FLOAT,
    popularity_snapshot INT,
    CONSTRAINT fk_features_track FOREIGN KEY (track_internal_id) REFERENCES Tracks(track_internal_id));

--One to Many : Tracks/Artist ke Bridge
--Implementasi Many-to-Many via Bridge Table
CREATE TABLE Track_Artist_Bridge (
    track_internal_id BIGINT,
    artist_id INT,
    is_main_artist BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (track_internal_id, artist_id),
    CONSTRAINT fk_bridge_track FOREIGN KEY (track_internal_id) REFERENCES Tracks(track_internal_id),
    CONSTRAINT fk_bridge_artist FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

--Zero to Many Users/Tracks ke History
--User/Track bisa ada tanpa harus ada di tabel ini.
CREATE TABLE Streaming_History (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    track_internal_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    play_duration_sec INT,
    platform VARCHAR(20),
    CONSTRAINT fk_history_track FOREIGN KEY (track_internal_id) REFERENCES Tracks(track_internal_id),
    CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ======================  DML  =================================
-- A. INSERT GENRES
INSERT INTO Genres (genre_name) VALUES 
('acoustic'), 
('pop');

-- B. INSERT ARTISTS (Termasuk pemisahan duet baris 3)
INSERT INTO Artists (artist_name, country_origin) VALUES 
('Gen Hoshino', 'JP'),
('Ben Woodward', 'GB'),
('Ingrid Michaelson', 'US'),
('ZAYN', 'GB'),
('Kina Grannis', 'US'),
('Chord Overstreet', 'US'),
('Tyrone Wells', 'US'),
('A Great Big World', 'US'),
('Jason Mraz', 'US'),
('Ross Copperman', 'US'),
('Zack Tabudlo', 'PH');

-- C. INSERT ALBUMS
INSERT INTO Albums (album_name, release_date) VALUES 
('Comedy', '2022-04-08'), 
('Ghost (Acoustic)', '2021-12-01'), 
('To Begin Again', '2020-05-20'), 
('Crazy Rich Asians (OST)', '2018-08-10'), 
('Hold On', '2017-02-03'), 
('Days I Will Remember', '2022-01-01'), 
('Is There Anybody Out There?', '2014-01-01'), 
('We Sing. We Dance. We Steal Things.', '2008-05-13'), 
('Hunger', '2016-01-01'), 
('Episode', '2021-10-15');

-- D. INSERT USERS (Dummy)
INSERT INTO Users (user_anon_token, region_code, age_group, gender) VALUES 
('u1-token', 'ID', '18-24', 'M'),
('u2-token', 'US', '25-34', 'F');

-- D2. INSERT ALBUMS (11-93) - Untuk Tracks 11-100
INSERT INTO Albums (album_name, release_date) VALUES 
('Tasty + B Sides', '2020-01-01'),
('Vibes', '2018-01-01'),
('Sus primeras grabaciones 1992-1994', '1994-01-01'),
('Buena Vista Social Club', '1997-09-16'),
('Zombie', '1976-01-01'),
('African Giant', '2019-07-26'),
('Made In Lagos', '2020-10-30'),
('A Good Time', '2019-11-22'),
('Rave & Roses', '2022-03-25'),
('Adult Themes', '2020-01-01'),
('Pocahontas (OST/Japanese Version)', '1995-01-01'),
('Disney Jingle Bell Fun', '2018-01-01'),
('Lullaby Renditions of Winnie the Pooh', '2019-01-01'),
('Dreamy Piano', '2020-01-01'),
('Encanto (Deutscher Original Film-Soundtrack)', '2021-11-19'),
('Encanto (OST)', '2021-11-19'),
('Frozen II', '2019-11-22'),
('Frozen', '2013-11-27'),
('Toy Story 4', '2019-06-21'),
('Aladdin (Originalt Norsk Soundtrack)', '1992-01-01'),
('Die bunte Seite des Monds', '2020-10-23'),
('Ferdinand the Bull and Friends', '2001-01-01'),
('Bambi', '1942-08-21'),
('Dumbo', '1941-10-23'),
('Encanto (Trilha Sonora Original em Português)', '2021-11-19'),
('Humanos', '2002-01-01'),
('Filho de Leão', '2007-01-01'),
('Histórias e Bicicletas', '2013-04-30'),
('Seleção de Ouro', '2001-01-01'),
('Deus Cuida de Mim', '1999-01-01'),
('Marca da Promessa', '2007-06-01'),
('Terremoto', '2005-01-01'),
('Apocalipse', '2008-01-01'),
('Faz Chover', '2004-01-01'),
('Advogado Fiel', '2009-08-14'),
('Memórias 2 (Ao Vivo)', '2022-05-13'),
('Há uma Saída', '2003-01-01'),
('Uma Questão de Fé', '2008-01-01'),
('Raridade', '2013-01-01'),
('Graça', '2013-01-01'),
('Compromisso', '2009-06-01'),
('Com Muito Louvor', '1999-01-01'),
('Preto no Branco (Ao Vivo)', '2015-12-18'),
('Pra Onde Iremos?', '2014-12-08'),
('Convida, Volume II', '1980-01-01'),
('Asu Maralman (Türk Pop Tarihi)', '1970-01-01'),
('Ways & Means', '2011-10-25'),
('Yeni Türkü Koleksiyon', '2013-01-01'),
('Gülümse', '1991-01-01'),
('Ebruli', '1996-01-01'),
('Mançoloji', '1999-01-01'),
('Merhaba Gençler ve Her Zaman Genç Kalanlar', '1987-01-01'),
('Elektronik Türküler', '1974-01-01'),
('Anadolu Pop', '1975-01-01'),
('Anthology', '2003-04-29'),
('It''s Time', '2005-02-08'),
('Michael Bublé', '2003-02-11'),
('Bunty Aur Babli', '2005-04-18'),
('Jab We Met', '2007-09-21'),
('Student of the Year', '2012-08-31'),
('MAP OF THE SOUL : PERSONA', '2019-04-12'),
('Love Yourself 結 ''Answer''', '2018-08-24'),
('Dynamite (DayTime Version)', '2020-08-21'),
('BE', '2020-11-20'),
('Pop Hits Now', '2020-01-01'),
('Human - Best Adult Pop Tunes', '2020-01-01'),
('Perfect Christmas Hits', '2020-01-01'),
('Coffee Moment', '2020-01-01'),
('Cuddle Up Christmas', '2020-01-01'),
('Christmas Music - Holiday Hits', '2020-01-01'),
('Feeling Good - Adult Pop Favorites', '2020-01-01'),
('Christmas Sweets', '2020-01-01'),
('Christmas Magic', '2020-01-01'),
('Rockin'' Around The Christmas Tree 2022', '2022-11-01'),
('Christmas 2022', '2022-11-01'),
('Vaaranam Aayiram (OST)', '2008-01-01'),
('Tu Mile Dil Khile - Single', '2021-05-15'),
('Half of My Heart', '2009-01-01'),
('I Don''t Care', '2019-05-10'),
('25', '2015-11-20'),
('24K Magic', '2016-11-18'),
('Music Of The Spheres', '2021-10-15'),
('After Hours', '2020-03-20');

-- E. INSERT TRACKS (Baris 1-10)
INSERT INTO Tracks (track_internal_id, track_spotify_id, track_name, duration_ms, is_explicit, album_id, genre_id) VALUES 
(1, '5SuOikwiRyPMVoIQDJUgSV', 'Comedy', 230666, FALSE, 1, 1),
(2, '4qPNDBW1i3p13qLCt0Ki3A', 'Ghost - Acoustic', 149610, FALSE, 2, 1),
(3, '1iJBSr7s7jYXzM8EGcbK5b', 'To Begin Again', 210826, FALSE, 3, 1),
(4, '6lfxq3CG4xtTiEg7opyCyx', 'Can''t Help Falling In Love', 201933, FALSE, 4, 1),
(5, '5vjLSffimiIP26QG5WcN2K', 'Hold On', 198853, FALSE, 5, 1),
(6, '01MVOl9KtXD5274Mkb4352', 'Days I Will Remember', 214240, FALSE, 6, 1),
(7, '6Vc5wAMmXdKIAM7WUoEb7N', 'Say Something', 218106, FALSE, 7, 1),
(8, '1EzrEOXmMHtzwbFCCopfC9', 'I''m Yours', 242946, FALSE, 8, 1),
(9, '2pKi1lW3D9SupDwrXtqGkn', 'Hunger', 205594, FALSE, 9, 1),
(10, '3KC36V4B8b8B8aZ8dZ8e8f', 'Give Me Your Forever', 215000, FALSE, 10, 2);

-- F. INSERT AUDIO FEATURES (1-10)
INSERT INTO Track_Audio_Features (track_internal_id, danceability, energy, valence, acousticness, instrumentalness, liveness, speechiness, tempo, loudness, popularity_snapshot) VALUES 
(1, 0.676, 0.461, 0.715, 0.0322, 0.000001, 0.358, 0.143, 87.917, -6.746, 73),
(2, 0.420, 0.166, 0.267, 0.9240, 0.000006, 0.101, 0.0763, 77.489, -17.235, 55),
(3, 0.438, 0.359, 0.120, 0.2100, 0.000000, 0.117, 0.0557, 76.332, -9.734, 57),
(4, 0.266, 0.059, 0.132, 0.9050, 0.000071, 0.132, 0.0363, 181.740, -18.515, 71),
(5, 0.618, 0.443, 0.167, 0.4690, 0.000000, 0.0829, 0.0526, 119.949, -9.681, 82),
(6, 0.688, 0.481, 0.289, 0.4050, 0.000003, 0.111, 0.0366, 125.029, -8.807, 74),
(7, 0.407, 0.147, 0.0765, 0.8570, 0.000003, 0.0913, 0.0355, 141.284, -8.822, 74),
(8, 0.703, 0.444, 0.712, 0.5590, 0.000000, 0.0973, 0.0414, 150.960, -9.331, 83),
(9, 0.669, 0.308, 0.190, 0.8830, 0.000000, 0.090, 0.031, 74.980, -10.068, 56),
(10, 0.550, 0.400, 0.350, 0.6000, 0.000000, 0.110, 0.040, 95.000, -8.500, 65);

-- G. INSERT BRIDGE (1-10)
INSERT INTO Track_Artist_Bridge (track_internal_id, artist_id, is_main_artist) VALUES 
(1, 1, TRUE),
(2, 2, TRUE),
(3, 3, TRUE),
(3, 4, FALSE),
(4, 5, TRUE),
(5, 6, TRUE),
(6, 7, TRUE),
(7, 8, TRUE),
(8, 9, TRUE),
(9, 10, TRUE),
(10, 11, TRUE);

-- =============================================================
-- 1.1. INSERT HISTORY (SIMULASI AWAL)
-- =============================================================

-- H. INSERT HISTORY (Simulasi 20 Transaksi)
INSERT INTO Streaming_History (track_internal_id, user_id, played_at, play_duration_sec, platform)
SELECT 1, 1, NOW(), 180, 'Spotify Android' UNION ALL
SELECT 5, 2, NOW(), 200, 'Spotify iOS';

-- =============================================================
-- =============================================================

INSERT INTO Genres (genre_name) VALUES 
('afrobeat'),
('disney'),
('gospel'),
('j-rock'),
('jazz'),
('indian'),
('k-pop');

INSERT INTO Artists (artist_name, country_origin) VALUES 

('Plastilina Mosh', 'MX'),
('Jor''dan Armstrong', 'US'),
('Jorge Drexler', 'UY'),
('Buena Vista Social Club', 'CU'),
('Fela Kuti', 'NG'),
('Burna Boy', 'NG'),
('Wizkid', 'NG'),
('Davido', 'NG'),
('Rema', 'NG'),
-- [BATCH 21-30: DISNEY & AFROBEAT]
('El Michels Affair', 'US'),
('Haruki Sayama', 'JP'),
('Ryoichi Fukuzawa', 'JP'),
('Yuko Doi', 'JP'),
('Music Creation', 'JP'),
('Donald Duck', 'US'),
('Goofy', 'US'),
('Billboard Baby Lullabies', 'US'),
('Cameron''s Bedtime Classics', 'US'),
('Germaine Franco', 'US'),
('Lin-Manuel Miranda', 'US'),
('Idina Menzel', 'US'),
('Kristen Bell', 'US'),
('Randy Newman', 'US'),
-- [BATCH 31-40: DISNEY NEW ARTISTS]
('Jannicke Kruse', 'NO'),
('Trond Teigen', 'NO'),
('Debby van Dooren', 'DE'),
('Tommy Amper', 'DE'),
('Friedel Morgenstern', 'DE'),
('David Ogden Stiers', 'US'),
('Chie Nagatani', 'JP'),
('Nina Flyer', 'US'),
('Frank Churchill', 'US'),
('Ed Plumb', 'US'),
('Larry Morey', 'US'),
('Oliver Wallace', 'US'),
-- [BATCH 41-50: GOSPEL ARTISTS (BRAZIL)]
('Oficina G3', 'BR'),
('Gerson Rufino', 'BR'),
('Sérgio Lopes', 'BR'),
('Kleber Lucas', 'BR'),
('Trazendo a Arca', 'BR'),
('Eyshila', 'BR'),
('Damares', 'BR'),
('Fernandinho', 'BR'),
('Bruna Karla', 'BR'),
-- [BATCH 51-60: GOSPEL NEW ARTISTS]
('Eli Soares', 'BR'),
('Shirley Carvalhaes', 'BR'),
('Késia Soares', 'BR'),
('Rose Nascimento', 'BR'),
('Anderson Freire', 'BR'),
('Aline Barros', 'BR'),
('Regis Danese', 'BR'),
('Cassiane', 'BR'),
('Preto no Branco', 'BR'),
('Gabriela Rocha', 'BR'),
-- [BATCH 61-70: J-ROCK / WORLD NEW ARTISTS]
('Erasmo Carlos', 'BR'),
('Chico Buarque', 'BR'),
('Asu Maralman', 'TR'),
('The Green', 'US'),
('Yeni Türkü', 'TR'),
('Sezen Aksu', 'TR'),
('Ezginin Günlüğü', 'TR'),
('Barış Manço', 'TR'),
('Cem Karaca', 'TR'),
('Erkin Koray', 'TR'),
('Moğollar', 'TR'),
-- [BATCH 71-80: JAZZ, INDIAN, K-POP NEW ARTISTS]
('Grover Washington, Jr.', 'US'),
('Bill Withers', 'US'),
('Michael Bublé', 'CA'),
('Shankar', 'IN'),
('Ehsaan', 'IN'),
('Loy', 'IN'),
('Alisha Chinai', 'IN'),
('Shankar Mahadevan', 'IN'),
('Gulzar', 'IN'),
('Pritam', 'IN'),
('Mohit Chauhan', 'IN'),
('Vishal-Shekhar', 'IN'),
('Vishal Dadlani', 'IN'),
('Shekhar Ravjiani', 'IN'),
('BTS', 'KR'),
('Halsey', 'US'),
-- [BATCH 91-100: JAZZ & POP NEW ARTISTS]
('Norah Jones', 'US'),
('Harris Jayaraj', 'IN'),
('Sudha Ragunathan', 'IN'),
('Raj Barman', 'IN'),
('John Mayer', 'US'),
('Taylor Swift', 'US'),
('Ed Sheeran', 'GB'),
('Justin Bieber', 'CA'),
('Adele', 'GB'),
('Bruno Mars', 'US'),
('Coldplay', 'GB'),
('Selena Gomez', 'US'),
('The Weeknd', 'CA');

-- =============================================================
-- 2. INSERT TRACKS (METADATA LAGU 11-100)
-- =============================================================

INSERT INTO Tracks (track_internal_id, track_spotify_id, track_name, duration_ms, is_explicit, album_id, genre_id) VALUES 

(11, '1a08XzvFiWYAgn5xZswA8o', 'Mr. P-Mosh', 257640, FALSE, 11, 3),
(12, '5sS5Jqw2h7WFw5yWVk3kPr', 'Count It', 177738, FALSE, 12, 3),
(13, '60KZzvMOCeuDMwT8yVp84N', 'El Sirenito', 235186, TRUE, 11, 3),
(14, '2Z3IaUbfcS8oqxmipQTkGh', 'La aparecida', 276906, FALSE, 13, 3),
(15, '1bv8XzvFiWYAgn5xZswSim', 'Chan Chan', 256000, FALSE, 14, 3),
(16, '2cv8XzvFiWYAgn5xZswSim', 'Zombie', 746000, FALSE, 15, 3),
(17, '3dv8XzvFiWYAgn5xZswSim', 'On The Low', 186000, FALSE, 16, 3),
(18, '4ev8XzvFiWYAgn5xZswSim', 'Essence', 240000, FALSE, 17, 3),
(19, '5fv8XzvFiWYAgn5xZswSim', 'Fall', 200000, FALSE, 18, 3),
(20, '6gv8XzvFiWYAgn5xZswSim', 'Calm Down', 219000, FALSE, 19, 3),
(21, '6J0HEZmMPkLGLljiW3mBJZ', 'Villa', 165735, FALSE, 20, 3),
(22, '08g09UHbKcqhXawnm5RV84', 'Savages (Part 2)', 135000, FALSE, 21, 4),
(23, '35corN4vO44BQSS0VsbwwX', 'Rudolph The Red-Nosed Reindeer', 154466, FALSE, 22, 4),
(24, '3Qq52P28qQHcFXZeoQmNSm', 'Hip Hip Pooh Rah', 88641, FALSE, 23, 4),
(25, '46rlcwBQ2LBL9AmhPC5E5D', 'Rocking Chair Lullaby', 169950, FALSE, 24, 4),
(26, '2TZR6L68PeBEMjpQjg2f9K', 'Die letzte Vision', 130639, FALSE, 25, 4),
(27, '5GUYJTQap5ld3TqjwE', 'We Don''t Talk About Bruno', 216000, FALSE, 26, 4),
(28, '27rQ2G1vWj5T8f6L5j', 'Into the Unknown', 194000, FALSE, 27, 4),
(29, '123FrozenTrackId', 'Do You Want to Build a Snowman?', 207000, FALSE, 28, 4),
(30, '456ToyStoryTrackId', 'I Can''t Let You Throw Yourself Away', 145000, FALSE, 29, 4),
(31, '1DZCuHlEykDCJ7xXhr30Ed', 'En helt ny verden', 161533, FALSE, 30, 4),
(32, '2QxSweibULGvxvM1WC1cXj', 'Im Mondenschein', 91466, FALSE, 31, 4),
(33, '0NEDcu00luOHzIFEqg8Kgv', 'The Carnival of the Animals: Kangaroos', 82208, FALSE, 32, 4),
(34, '4scMKnkTqijQP7JRrXj4UO', 'Bambi Gets Twitterpated', 152293, FALSE, 33, 4),
(35, '4wSMMFbMq7fonJuHFtLiNo', 'You Oughta Be Ashamed', 70840, FALSE, 34, 4),
(36, '6UbMnyEZI5rh0paFaL6guO', 'Tío Bruno', 143133, FALSE, 35, 4),
(37, 'SimDisney37', 'Circle of Life', 240000, FALSE, 26, 4),
(38, 'SimDisney38', 'Hakuna Matata', 210000, FALSE, 26, 4),
(39, 'SimDisney39', 'Let It Go', 220000, FALSE, 28, 4),
(40, 'SimDisney40', 'You''ve Got a Friend in Me', 180000, FALSE, 29, 4),
(41, '0f7TvXMUKeDDMyVjcGFqFm', 'Até Quando?', 214645, FALSE, 36, 5),
(42, '1JxbwPjI3lyjDDdTvF5O8W', 'Desta Vez Não', 216400, FALSE, 37, 5),
(43, '0MwitR6EAeWqA5tWL4uFvK', 'Diz', 339707, FALSE, 38, 5),
(44, '2n4kHDiB1JF7JKucWKwK4v', 'Tente Lembrar', 201084, FALSE, 39, 5),
(45, '3oZkyi8QZ0qJ7J7x5yW8rL', 'Deus Cuida de Mim', 245000, FALSE, 40, 5),
(46, '4pQ1wZ9y8x6r3t5uV7vW2X', 'Marca da Promessa', 300000, FALSE, 41, 5),
(47, '5qR2sA1bC4dEfG7hJ9kLmN', 'Terremoto', 280000, FALSE, 42, 5),
(48, '6rS3tB2cD5eFGH8iJ0kLmO', 'Sabor de Mel', 290000, FALSE, 43, 5),
(49, '7sT4uC3dE6fGHJ9kL0mNnP', 'Faz Chover', 310000, FALSE, 44, 5),
(50, '8tU5vD4eF7gHJ0kL1mNnPq', 'Advogado Fiel', 270000, FALSE, 45, 5),
(51, '3oIKT8CKqao4bulVol6Pf7', 'O Espírito Do Senhor - Ao Vivo', 319408, FALSE, 46, 5),
(52, '4rKgZ8OBMrn0wSmxVlqneH', 'Desapareceu um Povo', 234666, FALSE, 47, 5),
(53, '3c6LWNzVMK97JT5aMoKmBl', 'Corpo E Família - Ao Vivo', 307000, FALSE, 46, 5),
(54, '6y07btbdPt9vgKj5O7Rx1M', 'Ninguém Pode Impedir', 239053, FALSE, 48, 5),
(55, '0W5Y2G9X8H7U1V4F3Z6QpL', 'Raridade', 300000, FALSE, 49, 5),
(56, '1X9Y3H8I5U2W6G4A7R8SqM', 'Ressuscita-me', 280000, FALSE, 50, 5),
(57, '2Z4a9J7K6V3B5C8D9S0ToN', 'Faz um Milagre em Mim', 290000, FALSE, 51, 5),
(58, '3b5c8d9e0f1g2h3i4j5k6l', 'Com Muito Louvor', 310000, FALSE, 52, 5),
(59, '4c6d7e8f9g0h1i2j3k4l5m', 'Ninguém Explica Deus', 350000, FALSE, 53, 5),
(60, '5d7e8f9g0h1i2j3k4l5m6n', 'Lugar Secreto', 320000, FALSE, 54, 5),
(61, '1Ugz0VZmL522ZI4UrODbB5', 'Olha', 215066, FALSE, 55, 6),
(62, '2QD87WzfqnNWwiKNCEgJSq', 'Yollar', 170026, FALSE, 56, 6),
(63, '6HniH9hqshcK6b9lXqhxbx', 'Love Is Strong', 217426, FALSE, 57, 6),
(64, '4UYfhV2tepj0Sl1R7MGh6k', 'Sonbahardan Çizgiler', 210800, FALSE, 58, 6),
(65, '6vjLSffimiIP26QG5WcN2K', 'Gülümse', 280000, FALSE, 59, 6),
(66, '6xY3H8I5U2W6G4A7R8SqM', 'Düşler Sokağı', 260000, FALSE, 60, 6),
(67, '7y4a9J7K6V3B5C8D9S0ToN', 'Gülpembe', 290000, FALSE, 61, 6),
(68, '8z5c8d9e0f1g2h3i4j5k6l', 'Tamirci Çırağı', 300000, FALSE, 62, 6),
(69, '9a6d7e8f9g0h1i2j3k4l5m', 'Fesuphanallah', 220000, FALSE, 63, 6),
(70, '0b7e8f9g0h1i2j3k4l5m6n', 'Bi Şey Yapmalı', 240000, FALSE, 64, 6),
(71, '1ko2lVN0vKGUl9zrU0qSlT', 'Just the Two of Us', 438493, FALSE, 65, 7),
(72, '1AM8QdDFZMq6SrrqUnuQ9P', 'Feeling Good', 237333, FALSE, 66, 7),
(73, '2ajUl8lBLAXOXNpG4NEPMz', 'Sway', 188066, FALSE, 67, 7),
(74, '72HdutlIHBZJ7WT1xVAAZT', 'Kajra Re', 482586, FALSE, 68, 8),
(75, '2bPe17yY7f232X903rZ3Y8', 'Mauja Hi Mauja', 244493, FALSE, 69, 8),
(76, '747e908J8X778g101kL2mN', 'Radha', 341000, FALSE, 70, 8),
(77, '5GwZ2J28vM789vQ76wX5Y4', 'Boy With Luv', 229773, FALSE, 71, 9),
(78, '6HwZ2J28vM789vQ76wX5Y4', 'IDOL', 223000, FALSE, 72, 9),
(79, '7IwZ2J28vM789vQ76wX5Y4', 'Dynamite', 199054, FALSE, 73, 9),
(80, '8JwZ2J28vM789vQ76wX5Y4', 'Life Goes On', 207000, FALSE, 74, 9),
(81, '1uWxXVpl4ZXFT7d6CH7LBS', 'I''ll Never Not Love You', 218390, FALSE, 75, 7),
(82, '7lN6zxaP5KYQHKSAh7nWBs', 'Crazy Love', 213610, FALSE, 76, 7),
(83, '4DwWLKys3e3SRuJovxX7hz', 'It''s Beginning to Look a Lot Like Christmas', 206346, FALSE, 77, 7),
(84, '5mXkwFSEKXMDikxK6x6lDv', 'Love You Anymore', 182666, FALSE, 78, 7),
(85, '0Gjsi7CQFsZJUIUKQIxYQP', 'Christmas Lights', 220000, FALSE, 79, 7),
(86, '5K4W6rRCh71bcMaWqBfiTj', 'All I Want for Christmas Is You', 231506, FALSE, 80, 7),
(87, '2AGk2b3bs357C0j36r3X2Q', 'Home', 225146, FALSE, 81, 7),
(88, '4QhWbupniDd94eoZliTrzC', 'White Christmas', 204360, FALSE, 82, 7),
(89, '6s005452f7g8h9i0j1k2l3', 'Holly Jolly Christmas', 119840, FALSE, 83, 7),
(90, '7t116563g8h9i0j1k2l3m4', 'Santa Claus Is Coming to Town', 171693, FALSE, 83, 7),
(91, '3AQWkYhZm0okGpW5yTGxiA', 'Christmas Calling (Jolly Jones)', 200461, FALSE, 84, 7),
(92, '6lmmKOEjpbMr7RfC78PJvR', 'Wonderful Christmastime', 215000, FALSE, 85, 7),
(93, '2WO5nzB7QtKn9ZRc9Jkalt', 'Annul Maelae', 322506, FALSE, 86, 2),
(94, '5OCFWPgrCCNBukB3YrDD90', 'Tu Mile Dil Khile', 197716, FALSE, 87, 2),
(95, '13wIQbwSuQ4YFvD', 'Half of My Heart', 250000, FALSE, 88, 2),
(96, '24xIQbwSuQ4YFvD', 'I Don''t Care', 219000, FALSE, 89, 2),
(97, '35yIQbwSuQ4YFvD', 'Hello', 295000, FALSE, 90, 2),
(98, '46zIQbwSuQ4YFvD', '24K Magic', 226000, FALSE, 91, 2),
(99, '57aIQbwSuQ4YFvD', 'Let Somebody Go', 241000, FALSE, 92, 2),
(100, '68bIQbwSuQ4YFvD', 'Blinding Lights', 200000, FALSE, 93, 2); 

-- 3. INSERT AUDIO FEATURES (DATA 11-100)

INSERT INTO Track_Audio_Features (track_internal_id, danceability, energy, valence, acousticness, instrumentalness, liveness, speechiness, tempo, loudness, popularity_snapshot) VALUES 

(11, 0.791, 0.642, 0.477, 0.2130, 0.000279, 0.356, 0.182, 94.585, -8.502, 23),
(12, 0.517, 0.858, 0.055, 0.1320, 0.000000, 0.092, 0.103, 100.040, -5.168, 21),
(13, 0.671, 0.898, 0.875, 0.1100, 0.000026, 0.117, 0.771, 92.953, -6.861, 23),
(14, 0.539, 0.372, 0.569, 0.7480, 0.000000, 0.128, 0.045, 142.615, -14.152, 22),
(15, 0.650, 0.500, 0.600, 0.4000, 0.050000, 0.150, 0.050, 110.000, -9.500, 75),
(16, 0.850, 0.900, 0.800, 0.1000, 0.400000, 0.200, 0.100, 120.000, -5.500, 60),
(17, 0.780, 0.750, 0.700, 0.2500, 0.000000, 0.110, 0.080, 105.000, -6.000, 85),
(18, 0.720, 0.650, 0.680, 0.3000, 0.000000, 0.105, 0.060, 102.000, -7.500, 88),
(19, 0.800, 0.820, 0.750, 0.1500, 0.000000, 0.130, 0.070, 108.000, -5.200, 82),
(20, 0.850, 0.780, 0.880, 0.2000, 0.000000, 0.140, 0.090, 112.000, -4.800, 92),
(21, 0.503, 0.733, 0.377, 0.6760, 0.809000, 0.983, 0.188, 167.935, -7.272, 48),
(22, 0.221, 0.325, 0.195, 0.9120, 0.919000, 0.318, 0.553, 66.599, -14.880, 20),
(23, 0.555, 0.594, 0.504, 0.6240, 0.000000, 0.126, 0.242, 69.963, -7.189, 21),
(24, 0.244, 0.323, 0.359, 0.9680, 0.947000, 0.143, 0.464, 220.525, -18.836, 20),
(25, 0.713, 0.406, 0.272, 0.9930, 0.912000, 0.825, 0.232, 126.241, -17.008, 20),
(26, 0.191, 0.251, 0.375, 0.8770, 0.897000, 0.128, 0.369, 100.000, -14.046, 20),
(27, 0.570, 0.450, 0.620, 0.3000, 0.000000, 0.110, 0.080, 115.000, -6.500, 95),
(28, 0.480, 0.550, 0.450, 0.2500, 0.000000, 0.150, 0.060, 125.000, -5.500, 90),
(29, 0.600, 0.400, 0.700, 0.8500, 0.000000, 0.200, 0.150, 95.000, -8.000, 88),
(30, 0.750, 0.600, 0.850, 0.4000, 0.000050, 0.120, 0.050, 130.000, -6.000, 85),
-- [31-40]
(31, 0.244, 0.268, 0.226, 0.9940, 0.000000, 0.075, 0.0315, 85.732, -12.750, 20),
(32, 0.285, 0.471, 0.589, 0.1050, 0.000000, 0.319, 0.0918, 157.909, -7.567, 20),
(33, 0.602, 0.104, 0.214, 0.2080, 0.208000, 0.864, 0.0978, 111.549, -27.128, 20),
(34, 0.319, 0.241, 0.362, 0.2670, 0.431000, 0.343, 0.0794, 100.202, -16.786, 20),
(35, 0.181, 0.197, 0.002, 0.8660, 0.141000, 0.481, 0.0909, 101.809, -24.981, 21),
(36, 0.649, 0.330, 0.050, 0.1500, 0.000000, 0.120, 0.040, 110.000, -7.519, 19),
(37, 0.550, 0.600, 0.650, 0.2000, 0.000000, 0.150, 0.050, 120.000, -6.000, 85),
(38, 0.700, 0.550, 0.800, 0.1500, 0.000000, 0.200, 0.060, 115.000, -5.500, 88),
(39, 0.600, 0.700, 0.500, 0.1000, 0.000000, 0.250, 0.070, 130.000, -4.500, 92),
(40, 0.650, 0.500, 0.750, 0.2500, 0.000000, 0.180, 0.055, 110.000, -6.500, 80),
-- [41-50]
(41, 0.478, 0.869, 0.506, 0.7960, 0.714000, 0.385, 0.0470, 182.013, -5.228, 40),
(42, 0.690, 0.616, 0.385, 0.0000, 0.954000, 0.103, 0.0470, 74.992, -6.687, 39),
(43, 0.553, 0.917, 0.468, 0.0110, 0.309000, 0.204, 0.1350, 92.503, -3.438, 40),
(44, 0.400, 0.454, 0.351, 0.0000, 0.338000, 0.307, 0.2790, 143.400, -12.124, 39),
(45, 0.500, 0.600, 0.550, 0.2000, 0.000000, 0.150, 0.050, 120.000, -6.000, 75),
(46, 0.600, 0.700, 0.650, 0.1500, 0.000000, 0.200, 0.060, 115.000, -5.500, 78),
(47, 0.550, 0.650, 0.600, 0.1000, 0.000000, 0.180, 0.055, 110.000, -5.800, 80),
(48, 0.650, 0.750, 0.700, 0.0500, 0.000000, 0.220, 0.070, 125.000, -5.200, 82),
(49, 0.700, 0.800, 0.750, 0.0200, 0.000000, 0.250, 0.080, 130.000, -4.500, 85),
(50, 0.750, 0.850, 0.800, 0.0100, 0.000000, 0.280, 0.090, 135.000, -4.000, 88),
-- [51-60]
(51, 0.529, 0.403, 0.206, 0.3080, 0.000001, 0.348, 0.2370, 119.639, -10.665, 39),
(52, 0.576, 0.455, 0.390, 0.0280, 0.000000, 0.148, 0.7130, 77.075, -4.819, 39),
(53, 0.320, 0.384, 0.120, 0.3620, 0.000006, 0.805, 0.2960, 119.353, -10.710, 40),
(54, 0.525, 0.721, 0.342, 0.4130, 0.000000, 0.078, 0.7430, 140.000, -2.376, 40),
(55, 0.450, 0.600, 0.500, 0.2500, 0.000000, 0.180, 0.060, 125.000, -5.500, 82),
(56, 0.500, 0.650, 0.550, 0.2000, 0.000000, 0.200, 0.070, 130.000, -5.000, 85),
(57, 0.550, 0.700, 0.600, 0.1500, 0.000000, 0.220, 0.080, 135.000, -4.500, 88),
(58, 0.600, 0.750, 0.650, 0.1000, 0.000000, 0.250, 0.090, 140.000, -4.000, 90),
(59, 0.650, 0.800, 0.700, 0.0500, 0.000000, 0.280, 0.100, 145.000, -3.500, 92),
(60, 0.700, 0.850, 0.750, 0.0200, 0.000000, 0.300, 0.110, 150.000, -3.000, 95),
-- [61-70]
(61, 0.570, 0.375, 0.525, 0.7870, 0.457000, 0.128, 0.7750, 129.793, -12.068, 34),
(62, 0.679, 0.587, 0.775, 0.1860, 0.225000, 0.000, 0.1280, 139.914, -9.455, 33),
(63, 0.827, 0.559, 0.751, 0.6120, 0.452000, 0.000, 0.5320, 143.982, -6.252, 32),
(64, 0.568, 0.230, 0.303, 0.3430, 0.464000, 0.000, 0.1760, 105.872, -18.455, 33),
(65, 0.600, 0.500, 0.600, 0.4000, 0.000000, 0.150, 0.050, 110.000, -8.000, 80),
(66, 0.550, 0.450, 0.500, 0.6000, 0.000000, 0.180, 0.060, 100.000, -9.000, 75),
(67, 0.700, 0.750, 0.800, 0.2000, 0.000000, 0.220, 0.070, 130.000, -6.500, 90),
(68, 0.650, 0.800, 0.700, 0.1000, 0.000000, 0.250, 0.080, 140.000, -5.500, 92),
(69, 0.750, 0.850, 0.900, 0.0500, 0.000000, 0.300, 0.090, 150.000, -4.500, 95),
(70, 0.800, 0.900, 0.950, 0.0100, 0.000000, 0.350, 0.100, 160.000, -4.000, 98),
-- [71-80]
(71, 0.749, 0.497, 0.585, 0.4180, 0.000499, 0.504, 0.1050, 95.818, -12.609, 77),
(72, 0.535, 0.548, 0.477, 0.5330, 0.000001, 0.123, 0.0370, 115.144, -6.510, 73),
(73, 0.713, 0.639, 0.737, 0.7530, 0.000000, 0.878, 0.3130, 125.959, -5.529, 74),
(74, 0.484, 0.898, 0.680, 0.3650, 0.000000, 0.091, 0.1640, 91.975, -4.132, 59),
(75, 0.750, 0.900, 0.850, 0.1000, 0.000000, 0.150, 0.050, 130.000, -4.000, 65),
(76, 0.650, 0.800, 0.700, 0.1500, 0.000000, 0.200, 0.060, 140.000, -5.000, 70),
(77, 0.700, 0.850, 0.750, 0.1000, 0.000000, 0.100, 0.050, 120.000, -4.500, 85),
(78, 0.750, 0.900, 0.800, 0.0500, 0.000000, 0.200, 0.070, 125.000, -4.000, 88),
(79, 0.800, 0.950, 0.900, 0.0200, 0.000000, 0.150, 0.080, 115.000, -3.500, 92),
(80, 0.600, 0.700, 0.650, 0.2500, 0.000000, 0.300, 0.060, 100.000, -5.500, 82),
-- [81-90]
(81, 0.492, 0.791, 0.585, 0.1870, 0.000000, 0.110, 0.0500, 144.363, -5.045, 0),
(82, 0.492, 0.791, 0.585, 0.1870, 0.000000, 0.110, 0.0500, 144.363, -5.045, 1),
(83, 0.335, 0.232, 0.381, 0.9080, 0.000008, 0.292, 0.0334, 93.391, -11.042, 1),
(84, 0.693, 0.257, 0.603, 0.8690, 0.000000, 0.110, 0.0356, 90.014, -7.785, 0),
(85, 0.335, 0.232, 0.381, 0.9080, 0.000008, 0.292, 0.0334, 93.391, -11.042, 0),
(86, 0.399, 0.491, 0.315, 0.1250, 0.000000, 0.100, 0.0366, 150.147, -6.681, 0),
(87, 0.583, 0.417, 0.294, 0.7720, 0.000002, 0.088, 0.0322, 126.319, -7.236, 0),
(88, 0.430, 0.219, 0.347, 0.9330, 0.000025, 0.102, 0.0334, 118.667, -12.891, 0),
(89, 0.677, 0.517, 0.817, 0.6590, 0.000000, 0.354, 0.0315, 151.139, -5.907, 0),
(90, 0.551, 0.890, 0.793, 0.1770, 0.000000, 0.222, 0.0400, 160.000, -4.299, 0),
-- [91-100: JAZZ & POP FILE BARU] (CLEANED)
(91, 0.430, 0.543, 0.354, 0.4630, 0.000523, 0.928, 0.3670, 143.912, -6.296, 0),
(92, 0.430, 0.543, 0.354, 0.4630, 0.000523, 0.928, 0.3670, 143.912, -6.296, 0),
(93, 0.773, 0.436, 0.533, 0.6720, 0.000678, 0.197, 0.3210, 115.917, -10.972, 64),
(94, 0.639, 0.368, 0.415, 0.2450, 0.000000, 0.106, 0.0480, 89.940, -14.096, 62),
(95, 0.500, 0.600, 0.550, 0.2000, 0.000000, 0.150, 0.0500, 120.000, -6.000, 95),
(96, 0.600, 0.700, 0.650, 0.1500, 0.000000, 0.200, 0.0600, 115.000, -5.500, 98),
(97, 0.550, 0.650, 0.600, 0.1000, 0.000000, 0.180, 0.0550, 110.000, -5.800, 100),
(98, 0.650, 0.750, 0.700, 0.0500, 0.000000, 0.220, 0.0700, 125.000, -5.200, 92),
(99, 0.700, 0.800, 0.750, 0.0200, 0.000000, 0.250, 0.0800, 130.000, -4.500, 85),
(100, 0.750, 0.850, 0.800, 0.0100, 0.000000, 0.280, 0.0900, 135.000, -4.000, 88);

-- 4. INSERT BRIDGE (ARTIS 11-100)
INSERT INTO Track_Artist_Bridge (track_internal_id, artist_id, is_main_artist) VALUES 

(11, 12, TRUE), (12, 13, TRUE), (13, 12, TRUE), (14, 14, TRUE), 
(15, 15, TRUE), (16, 16, TRUE), (17, 17, TRUE), (18, 18, TRUE), (19, 19, TRUE), (20, 20, TRUE),

(21, 21, TRUE),
(22, 22, TRUE), (22, 23, FALSE), (22, 24, FALSE), (22, 25, FALSE),
(23, 26, TRUE), (23, 27, FALSE),
(24, 28, TRUE), (25, 29, TRUE), (26, 30, TRUE),
(27, 31, TRUE), (28, 32, TRUE), (29, 33, TRUE), (30, 34, TRUE),
-- [31-40]
(31, 35, TRUE), (31, 36, FALSE),
(32, 37, TRUE), (32, 38, FALSE), (32, 39, FALSE),
(33, 40, TRUE), (33, 41, FALSE), (33, 42, FALSE),
(34, 43, TRUE), (34, 44, FALSE), (34, 45, FALSE),
(35, 46, TRUE), (35, 43, FALSE),
(36, 30, TRUE),
(37, 31, TRUE), (38, 31, TRUE), (39, 32, TRUE), (40, 34, TRUE),
-- [41-50]
(41, 47, TRUE),
(42, 48, TRUE),
(43, 47, TRUE),
(44, 49, TRUE),
(45, 50, TRUE), (46, 51, TRUE), (47, 52, TRUE), 
(48, 53, TRUE), (49, 54, TRUE), (50, 55, TRUE),
-- [51-60]
(51, 56, TRUE),
(52, 57, TRUE),
(53, 56, TRUE), (53, 58, FALSE),
(54, 59, TRUE),
(55, 60, TRUE), (56, 61, TRUE), (57, 62, TRUE), 
(58, 63, TRUE), (59, 64, TRUE), (60, 65, TRUE),
-- [61-70]
(61, 66, TRUE), (61, 67, FALSE),
(62, 68, TRUE),
(63, 69, TRUE),
(64, 70, TRUE),
(65, 71, TRUE), (66, 72, TRUE), (67, 73, TRUE),
(68, 74, TRUE), (69, 75, TRUE), (70, 76, TRUE),
-- [71-80]
(71, 77, TRUE), (71, 78, FALSE),
(72, 79, TRUE), (73, 79, TRUE),
(74, 80, TRUE), (74, 81, FALSE), (74, 82, FALSE), 
(74, 83, FALSE), (74, 84, FALSE), (74, 85, FALSE),
(75, 86, TRUE), (75, 87, FALSE),
(76, 88, TRUE), (76, 89, FALSE), (76, 90, FALSE),
(77, 91, TRUE), (77, 92, FALSE),
(78, 91, TRUE), (79, 91, TRUE), (80, 91, TRUE),
-- [81-90]
(81, 79, TRUE),
(82, 79, TRUE),
(83, 79, TRUE),
(84, 79, TRUE),
(85, 79, TRUE),
(86, 79, TRUE),
(87, 79, TRUE),
(88, 79, TRUE),
(89, 79, TRUE),
(90, 79, TRUE),
-- [91-100: JAZZ & POP SPLIT]
(91, 93, TRUE),
(92, 93, TRUE),
(93, 94, TRUE), (93, 95, FALSE),
(94, 96, TRUE),
(95, 97, TRUE), (95, 98, FALSE),
(96, 99, TRUE), (96, 100, FALSE),
(97, 101, TRUE),
(98, 102, TRUE),
(99, 103, TRUE), (99, 104, FALSE),
(100, 105, TRUE);

-- 5. INSERT HISTORY (SIMULASI TAMBAHAN
INSERT INTO Streaming_History (track_internal_id, user_id, played_at, play_duration_sec, platform)
SELECT 93, 4, NOW(), 322, 'Spotify Android' UNION ALL
SELECT 100, 3, NOW(), 200, 'Spotify Desktop' UNION ALL
SELECT 27, 2, NOW(), 216, 'Spotify iOS';