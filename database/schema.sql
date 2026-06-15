-- ═══════════════════════════════════════════════════════════════════════════
--  THINKORA — PostgreSQL Schema v1.0
-- ═══════════════════════════════════════════════════════════════════════════

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ─── Users ──────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username            VARCHAR(30)  NOT NULL UNIQUE,
    email               VARCHAR(255) NOT NULL UNIQUE,
    password_hash       VARCHAR(255),
    display_name        VARCHAR(100) NOT NULL,
    avatar_url          TEXT,
    age                 SMALLINT     NOT NULL CHECK (age >= 3 AND age <= 120),
    age_group           VARCHAR(20)  NOT NULL CHECK (age_group IN ('explorer','adventurer','scholar','challenger','pioneer')),
    country             VARCHAR(50)  NOT NULL DEFAULT 'Unknown',
    google_id           VARCHAR(255) UNIQUE,
    apple_id            VARCHAR(255) UNIQUE,
    is_parent_account   BOOLEAN      NOT NULL DEFAULT false,
    parent_id           UUID         REFERENCES users(id) ON DELETE SET NULL,
    is_active           BOOLEAN      NOT NULL DEFAULT true,
    is_verified         BOOLEAN      NOT NULL DEFAULT false,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    last_active_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email    ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_country  ON users(country);
CREATE INDEX idx_users_age_group ON users(age_group);
CREATE INDEX idx_users_parent   ON users(parent_id) WHERE parent_id IS NOT NULL;

-- ─── TCI Ratings ────────────────────────────────────────────────────────────
CREATE TABLE tci_ratings (
    user_id          UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    overall          SMALLINT  NOT NULL DEFAULT 500 CHECK (overall >= 0 AND overall <= 9999),
    logic            SMALLINT  NOT NULL DEFAULT 500 CHECK (logic >= 0),
    memory           SMALLINT  NOT NULL DEFAULT 500 CHECK (memory >= 0),
    focus            SMALLINT  NOT NULL DEFAULT 500 CHECK (focus >= 0),
    strategy         SMALLINT  NOT NULL DEFAULT 500 CHECK (strategy >= 0),
    mathematics      SMALLINT  NOT NULL DEFAULT 500 CHECK (mathematics >= 0),
    creativity       SMALLINT  NOT NULL DEFAULT 500 CHECK (creativity >= 0),
    problem_solving  SMALLINT  NOT NULL DEFAULT 500 CHECK (problem_solving >= 0),
    learning_speed   SMALLINT  NOT NULL DEFAULT 500 CHECK (learning_speed >= 0),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tci_overall    ON tci_ratings(overall DESC);

-- ─── User Stats ─────────────────────────────────────────────────────────────
CREATE TABLE user_stats (
    user_id                UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_xp               INTEGER     NOT NULL DEFAULT 0,
    level                  SMALLINT    NOT NULL DEFAULT 1,
    current_streak         SMALLINT    NOT NULL DEFAULT 0,
    longest_streak         SMALLINT    NOT NULL DEFAULT 0,
    challenges_completed   INTEGER     NOT NULL DEFAULT 0,
    challenges_attempted   INTEGER     NOT NULL DEFAULT 0,
    battles_won            INTEGER     NOT NULL DEFAULT 0,
    battles_lost           INTEGER     NOT NULL DEFAULT 0,
    total_playtime_minutes INTEGER     NOT NULL DEFAULT 0,
    last_activity_date     DATE,
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Challenges ─────────────────────────────────────────────────────────────
CREATE TABLE challenges (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    realm_id          VARCHAR(30) NOT NULL,
    type              VARCHAR(50) NOT NULL,
    difficulty        VARCHAR(20) NOT NULL CHECK (difficulty IN ('beginner','intermediate','advanced','expert','master')),
    title             VARCHAR(200) NOT NULL,
    description       TEXT,
    content           JSONB NOT NULL,
    time_limit_seconds SMALLINT NOT NULL DEFAULT 60,
    xp_reward         SMALLINT NOT NULL DEFAULT 30,
    tci_delta         SMALLINT NOT NULL DEFAULT 8,
    dimension_deltas  JSONB NOT NULL DEFAULT '{}',
    tags              TEXT[] NOT NULL DEFAULT '{}',
    age_group         VARCHAR(20),
    is_ai_generated   BOOLEAN NOT NULL DEFAULT false,
    play_count        INTEGER NOT NULL DEFAULT 0,
    correct_rate      FLOAT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_challenges_realm      ON challenges(realm_id);
CREATE INDEX idx_challenges_difficulty ON challenges(difficulty);
CREATE INDEX idx_challenges_type       ON challenges(type);
CREATE INDEX idx_challenges_age_group  ON challenges(age_group);
CREATE INDEX idx_challenges_tags       ON challenges USING GIN(tags);
CREATE INDEX idx_challenges_content    ON challenges USING GIN(content);

-- ─── Challenge Attempts ─────────────────────────────────────────────────────
CREATE TABLE challenge_attempts (
    id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id            UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id       UUID        NOT NULL REFERENCES challenges(id),
    is_correct         BOOLEAN     NOT NULL,
    selected_answer    VARCHAR(10),
    time_spent_seconds SMALLINT    NOT NULL,
    xp_earned          SMALLINT    NOT NULL DEFAULT 0,
    tci_change         SMALLINT    NOT NULL DEFAULT 0,
    hints_used         SMALLINT    NOT NULL DEFAULT 0,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_attempts_user       ON challenge_attempts(user_id, created_at DESC);
CREATE INDEX idx_attempts_challenge  ON challenge_attempts(challenge_id);
CREATE INDEX idx_attempts_date       ON challenge_attempts(created_at DESC);
CREATE INDEX idx_attempts_user_date  ON challenge_attempts(user_id, created_at);

-- Update challenge stats trigger
CREATE OR REPLACE FUNCTION update_challenge_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE challenges SET
        play_count = play_count + 1,
        correct_rate = (
            SELECT AVG(CASE WHEN is_correct THEN 1.0 ELSE 0.0 END)
            FROM challenge_attempts
            WHERE challenge_id = NEW.challenge_id
        )
    WHERE id = NEW.challenge_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_attempt_insert
AFTER INSERT ON challenge_attempts
FOR EACH ROW EXECUTE FUNCTION update_challenge_stats();

-- ─── Realm Progress ─────────────────────────────────────────────────────────
CREATE TABLE realm_progress (
    user_id         UUID     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    realm_id        VARCHAR(30) NOT NULL,
    current_level   SMALLINT NOT NULL DEFAULT 1,
    stars_earned    INTEGER  NOT NULL DEFAULT 0,
    boss_defeated   BOOLEAN  NOT NULL DEFAULT false,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, realm_id)
);

-- ─── Achievements ───────────────────────────────────────────────────────────
CREATE TABLE achievements (
    id          VARCHAR(50) PRIMARY KEY,
    title       VARCHAR(100) NOT NULL,
    description TEXT         NOT NULL,
    icon        VARCHAR(10)  NOT NULL,
    category    VARCHAR(30)  NOT NULL,
    rarity      VARCHAR(20)  NOT NULL CHECK (rarity IN ('common','uncommon','rare','epic','legendary')),
    xp_reward   INTEGER      NOT NULL DEFAULT 100,
    requirement JSONB        NOT NULL DEFAULT '{}'
);

CREATE TABLE user_achievements (
    user_id        UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(50) NOT NULL REFERENCES achievements(id),
    unlocked_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);

-- ─── Daily Quests ───────────────────────────────────────────────────────────
CREATE TABLE daily_quests (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title         VARCHAR(200) NOT NULL,
    description   TEXT,
    challenge_ids UUID[]       NOT NULL,
    total_xp_reward SMALLINT  NOT NULL DEFAULT 50,
    age_group     VARCHAR(20)  NOT NULL,
    date          DATE         NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_daily_quests_date_age ON daily_quests(date, age_group);

CREATE TABLE user_daily_quests (
    user_id         UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quest_id        UUID    NOT NULL REFERENCES daily_quests(id),
    completed_count SMALLINT NOT NULL DEFAULT 0,
    is_completed    BOOLEAN  NOT NULL DEFAULT false,
    completed_at    TIMESTAMPTZ,
    PRIMARY KEY (user_id, quest_id)
);

-- ─── Battle Sessions ─────────────────────────────────────────────────────────
CREATE TABLE battle_sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id    UUID        REFERENCES challenges(id),
    player1_id      UUID        NOT NULL REFERENCES users(id),
    player2_id      UUID        NOT NULL REFERENCES users(id),
    player1_score   SMALLINT,
    player2_score   SMALLINT,
    winner_id       UUID        REFERENCES users(id),
    status          VARCHAR(20) NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting','active','completed','abandoned')),
    started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at        TIMESTAMPTZ
);

CREATE INDEX idx_battles_players ON battle_sessions(player1_id, player2_id);
CREATE INDEX idx_battles_status  ON battle_sessions(status);

-- ─── TCI History (for progress tracking) ─────────────────────────────────────
CREATE TABLE tci_history (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    overall    SMALLINT NOT NULL,
    recorded_at DATE   NOT NULL DEFAULT CURRENT_DATE
);

CREATE UNIQUE INDEX idx_tci_history_user_date ON tci_history(user_id, recorded_at);

-- Record TCI daily snapshot
CREATE OR REPLACE FUNCTION snapshot_tci()
RETURNS void AS $$
BEGIN
    INSERT INTO tci_history (user_id, overall, recorded_at)
    SELECT user_id, overall, CURRENT_DATE
    FROM tci_ratings
    ON CONFLICT (user_id, recorded_at) DO UPDATE
    SET overall = EXCLUDED.overall;
END;
$$ LANGUAGE plpgsql;

-- ─── Seed Achievements ──────────────────────────────────────────────────────
INSERT INTO achievements (id, title, description, icon, category, rarity, xp_reward, requirement)
VALUES
    ('streak_3',       'On Fire',           'Maintain a 3-day streak',               '🔥', 'streak',     'common',    100,  '{"streak_days": 3}'),
    ('streak_7',       'Week Warrior',      'Maintain a 7-day streak',               '⚡', 'streak',     'uncommon',  250,  '{"streak_days": 7}'),
    ('streak_30',      'Month Master',      'Maintain a 30-day streak',              '🌟', 'streak',     'rare',      1000, '{"streak_days": 30}'),
    ('streak_100',     'Century Mind',      'Maintain a 100-day streak',             '💎', 'streak',     'legendary', 5000, '{"streak_days": 100}'),
    ('challenges_10',  'First Steps',       'Complete 10 challenges',                '🎯', 'challenges', 'common',    150,  '{"challenges_completed": 10}'),
    ('challenges_100', 'Challenge Seeker',  'Complete 100 challenges',               '🏆', 'challenges', 'uncommon',  500,  '{"challenges_completed": 100}'),
    ('challenges_1000','Challenge Titan',   'Complete 1000 challenges',              '👑', 'challenges', 'epic',      5000, '{"challenges_completed": 1000}'),
    ('tci_1200',       'Intermediate Mind', 'Reach TCI 1200',                        '🧠', 'tci',        'uncommon',  500,  '{"tci_overall": 1200}'),
    ('tci_2000',       'Advanced Thinker',  'Reach TCI 2000',                        '⚡', 'tci',        'rare',      2000, '{"tci_overall": 2000}'),
    ('tci_3000',       'Grandmaster',       'Reach TCI 3000',                        '🌌', 'tci',        'legendary', 10000,'{"tci_overall": 3000}'),
    ('battles_1',      'First Blood',       'Win your first Brain Battle',           '⚔️', 'battles',   'common',    200,  '{"battles_won": 1}'),
    ('battles_50',     'Battle Hardened',   'Win 50 Brain Battles',                  '🛡️', 'battles',   'epic',      3000, '{"battles_won": 50}'),
    ('friends_5',      'Social Thinker',    'Add 5 friends',                         '🤝', 'social',     'common',    100,  '{"friends_count": 5}'),
    ('speed_master',   'Speed Demon',       'Complete a challenge in under 10s',     '💨', 'speed',      'rare',      750,  '{"challenge_time_seconds": 10}'),
    ('all_realms',     'World Explorer',    'Complete a level in every realm',       '🗺️', 'exploration','epic',      2500, '{"realms_explored": 7}'),
    ('realm_mastery',  'Realm Conqueror',   'Complete all levels in any realm',      '🏰', 'mastery',    'legendary', 7500, '{"realm_completed": 1}')
ON CONFLICT DO NOTHING;

-- ─── Views ───────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW leaderboard_view AS
SELECT
    ROW_NUMBER() OVER (ORDER BY t.overall DESC) as global_rank,
    u.id, u.username, u.display_name, u.avatar_url, u.country, u.age_group,
    t.overall as tci_overall,
    CASE
        WHEN t.overall >= 3000 THEN 'Grandmaster'
        WHEN t.overall >= 2800 THEN 'Master'
        WHEN t.overall >= 2500 THEN 'Expert'
        WHEN t.overall >= 2000 THEN 'Advanced'
        WHEN t.overall >= 1200 THEN 'Intermediate'
        ELSE 'Beginner'
    END as tci_tier,
    s.current_streak,
    s.total_xp,
    s.challenges_completed,
    s.battles_won
FROM users u
JOIN tci_ratings t ON t.user_id = u.id
JOIN user_stats s ON s.user_id = u.id
WHERE u.is_active = true;
