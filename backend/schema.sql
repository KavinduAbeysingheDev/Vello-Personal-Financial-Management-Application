-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USER PROFILES (Surface data for public schema)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    name TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- CONNECTED ACCOUNTS (SMS/Gmail metadata)
-- Tracks OAuth connections like Gmail separately from the main Supabase Auth user
-- ==============================================================================
CREATE TABLE IF NOT EXISTS connected_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    provider TEXT NOT NULL,
    provider_email TEXT,
    provider_user_id TEXT,
    status TEXT DEFAULT 'connected',
    access_scope TEXT,
    last_synced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 2. RAW IMPORTS
-- Stores raw unstructured data (SMS text, Gmail body) before parsing
-- ==============================================================================
CREATE TABLE IF NOT EXISTS raw_imports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    source_type TEXT NOT NULL,
    external_id TEXT NOT NULL,
    sender TEXT,
    subject TEXT,
    raw_text TEXT,
    transaction_date TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    imported_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_raw_import UNIQUE (user_id, source_type, external_id)
);

-- ==============================================================================
-- 3. TRANSACTIONS
-- The final normalized transaction data
-- ==============================================================================
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    raw_import_id UUID REFERENCES raw_imports(id) ON DELETE SET NULL,
    source_type TEXT NOT NULL,
    merchant TEXT,
    amount NUMERIC,
    currency TEXT DEFAULT 'LKR',
    category TEXT,
    transaction_date TIMESTAMPTZ,
    external_id TEXT,
    confidence_score NUMERIC DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Useful indexes for frequent queries
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date);

-- ==============================================================================
-- 4. SYNC LOGS
-- Tracks the success/failure of background imports
-- ==============================================================================
CREATE TABLE IF NOT EXISTS sync_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    source_type TEXT NOT NULL,
    status TEXT,
    message TEXT,
    items_scanned INTEGER DEFAULT 0,
    items_imported INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- Secure tables so users can only access their own data
-- ==============================================================================

ALTER TABLE connected_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE raw_imports ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_logs ENABLE ROW LEVEL SECURITY;

-- connected_accounts policies
CREATE POLICY "Users can view their own connected accounts" 
ON connected_accounts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own connected accounts" 
ON connected_accounts FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own connected accounts" 
ON connected_accounts FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own connected accounts" 
ON connected_accounts FOR DELETE USING (auth.uid() = user_id);

-- raw_imports policies
CREATE POLICY "Users can view their own raw imports" 
ON raw_imports FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own raw imports" 
ON raw_imports FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own raw imports" 
ON raw_imports FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own raw imports" 
ON raw_imports FOR DELETE USING (auth.uid() = user_id);

-- transactions policies
CREATE POLICY "Users can view their own transactions" 
ON transactions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own transactions" 
ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own transactions" 
ON transactions FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own transactions" 
ON transactions FOR DELETE USING (auth.uid() = user_id);

-- sync_logs policies
CREATE POLICY "Users can view their own sync logs" 
ON sync_logs FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sync logs" 
ON sync_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sync logs" 
ON sync_logs FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sync logs" 
ON sync_logs FOR DELETE USING (auth.uid() = user_id);

-- ==============================================================================
-- 5. SAVINGS GOALS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS savings_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    title TEXT NOT NULL,
    target_amount NUMERIC NOT NULL,
    current_amount NUMERIC DEFAULT 0,
    icon_str TEXT,
    color_hex TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE savings_goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access their own savings goals" ON savings_goals FOR ALL USING (auth.uid() = user_id);

-- ==============================================================================
-- 6. SUBSCRIPTIONS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    name TEXT NOT NULL,
    cost NUMERIC NOT NULL,
    billing_cycle TEXT,
    next_billing_date TIMESTAMPTZ,
    logo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access their own subscriptions" ON subscriptions FOR ALL USING (auth.uid() = user_id);

-- ==============================================================================
-- 7. DEBTS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS debts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    name TEXT NOT NULL,
    total_amount NUMERIC NOT NULL,
    paid_amount NUMERIC DEFAULT 0,
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 8. CHAT MESSAGES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    text TEXT NOT NULL,
    type TEXT NOT NULL, -- 'user' or 'ai'
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 9. BUDGETS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    category TEXT NOT NULL,
    amount_limit NUMERIC NOT NULL,
    current_spent NUMERIC DEFAULT 0,
    period TEXT DEFAULT 'monthly', -- 'weekly', 'monthly', 'yearly'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_category_budget UNIQUE (user_id, category, period)
);

ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access their own budgets" ON budgets FOR ALL USING (auth.uid() = user_id);

-- chat_messages policies
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own chat messages" ON chat_messages FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own chat messages" ON chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own chat messages" ON chat_messages FOR DELETE USING (auth.uid() = user_id);

-- debts policies
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access their own debts" ON debts FOR ALL USING (auth.uid() = user_id);
