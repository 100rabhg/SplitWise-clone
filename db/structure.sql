\restrict pbz87cofAYgvbQE57N3Uhmfy3lq8Kfhzx1oimpJ3qgtmsYau3259wRPE4gXRUne

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: expense_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expense_items (
    id bigint NOT NULL,
    type character varying NOT NULL,
    transaction_id bigint NOT NULL,
    name character varying NOT NULL,
    amount numeric(10,2) NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: expense_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.expense_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expense_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.expense_items_id_seq OWNED BY public.expense_items.id;


--
-- Name: friendships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendships (
    id bigint NOT NULL,
    user_1_id bigint NOT NULL,
    user_2_id bigint NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_order CHECK ((user_1_id < user_2_id))
);


--
-- Name: flat_friendships; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.flat_friendships AS
 SELECT friendships.id,
    friendships.user_1_id AS user_id,
    friendships.user_2_id AS friend_id,
    friendships.deleted_at
   FROM public.friendships
UNION
 SELECT friendships.id,
    friendships.user_2_id AS user_id,
    friendships.user_1_id AS friend_id,
    friendships.deleted_at
   FROM public.friendships;


--
-- Name: friendship_balances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendship_balances (
    id bigint NOT NULL,
    friendship_id bigint NOT NULL,
    balance numeric(10,2) DEFAULT 0.0 NOT NULL,
    owes_to_id bigint NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: friendship_balances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendship_balances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendship_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendship_balances_id_seq OWNED BY public.friendship_balances.id;


--
-- Name: friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendships_id_seq OWNED BY public.friendships.id;


--
-- Name: item_splits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_splits (
    id bigint NOT NULL,
    expense_item_id bigint NOT NULL,
    user_id bigint NOT NULL,
    friendship_id bigint,
    amount numeric(10,2) NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: item_splits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_splits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_splits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_splits_id_seq OWNED BY public.item_splits.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id bigint NOT NULL,
    type character varying NOT NULL,
    paid_by_id bigint,
    friendship_id bigint,
    amount numeric(10,2) NOT NULL,
    notes text,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: user_balances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_balances (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    total_due numeric(10,2) DEFAULT 0.0 NOT NULL,
    total_owed numeric(10,2) DEFAULT 0.0 NOT NULL,
    net_balance numeric(10,2) DEFAULT 0.0 NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_balances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_balances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_balances_id_seq OWNED BY public.user_balances.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    mobile_number character varying,
    deleted_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: expense_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expense_items ALTER COLUMN id SET DEFAULT nextval('public.expense_items_id_seq'::regclass);


--
-- Name: friendship_balances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendship_balances ALTER COLUMN id SET DEFAULT nextval('public.friendship_balances_id_seq'::regclass);


--
-- Name: friendships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships ALTER COLUMN id SET DEFAULT nextval('public.friendships_id_seq'::regclass);


--
-- Name: item_splits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_splits ALTER COLUMN id SET DEFAULT nextval('public.item_splits_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: user_balances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_balances ALTER COLUMN id SET DEFAULT nextval('public.user_balances_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: expense_items expense_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expense_items
    ADD CONSTRAINT expense_items_pkey PRIMARY KEY (id);


--
-- Name: friendship_balances friendship_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendship_balances
    ADD CONSTRAINT friendship_balances_pkey PRIMARY KEY (id);


--
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: item_splits item_splits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_splits
    ADD CONSTRAINT item_splits_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: user_balances user_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_balances
    ADD CONSTRAINT user_balances_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_expense_items_on_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_expense_items_on_transaction_id ON public.expense_items USING btree (transaction_id);


--
-- Name: index_friendship_balances_on_friendship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendship_balances_on_friendship_id ON public.friendship_balances USING btree (friendship_id);


--
-- Name: index_friendship_balances_on_friendship_id_and_owes_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendship_balances_on_friendship_id_and_owes_to_id ON public.friendship_balances USING btree (friendship_id, owes_to_id);


--
-- Name: index_friendship_balances_on_owes_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendship_balances_on_owes_to_id ON public.friendship_balances USING btree (owes_to_id);


--
-- Name: index_friendships_on_user_1_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_user_1_id ON public.friendships USING btree (user_1_id);


--
-- Name: index_friendships_on_user_1_id_and_user_2_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendships_on_user_1_id_and_user_2_id ON public.friendships USING btree (user_1_id, user_2_id);


--
-- Name: index_friendships_on_user_2_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_user_2_id ON public.friendships USING btree (user_2_id);


--
-- Name: index_item_splits_on_expense_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_splits_on_expense_item_id ON public.item_splits USING btree (expense_item_id);


--
-- Name: index_item_splits_on_friendship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_splits_on_friendship_id ON public.item_splits USING btree (friendship_id);


--
-- Name: index_item_splits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_splits_on_user_id ON public.item_splits USING btree (user_id);


--
-- Name: index_transactions_on_friendship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transactions_on_friendship_id ON public.transactions USING btree (friendship_id);


--
-- Name: index_transactions_on_paid_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transactions_on_paid_by_id ON public.transactions USING btree (paid_by_id);


--
-- Name: index_transactions_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transactions_on_type ON public.transactions USING btree (type);


--
-- Name: index_user_balances_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_balances_on_user_id ON public.user_balances USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: item_splits fk_rails_06f138aaed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_splits
    ADD CONSTRAINT fk_rails_06f138aaed FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: friendships fk_rails_155b018f3b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT fk_rails_155b018f3b FOREIGN KEY (user_2_id) REFERENCES public.users(id);


--
-- Name: friendship_balances fk_rails_1c49c6ae8e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendship_balances
    ADD CONSTRAINT fk_rails_1c49c6ae8e FOREIGN KEY (owes_to_id) REFERENCES public.users(id);


--
-- Name: user_balances fk_rails_2028b6ee02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_balances
    ADD CONSTRAINT fk_rails_2028b6ee02 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: expense_items fk_rails_32add1dee4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expense_items
    ADD CONSTRAINT fk_rails_32add1dee4 FOREIGN KEY (transaction_id) REFERENCES public.transactions(id);


--
-- Name: friendships fk_rails_7e88166851; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT fk_rails_7e88166851 FOREIGN KEY (user_1_id) REFERENCES public.users(id);


--
-- Name: friendship_balances fk_rails_b68081e617; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendship_balances
    ADD CONSTRAINT fk_rails_b68081e617 FOREIGN KEY (friendship_id) REFERENCES public.friendships(id);


--
-- Name: transactions fk_rails_b888575267; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_rails_b888575267 FOREIGN KEY (friendship_id) REFERENCES public.friendships(id);


--
-- Name: item_splits fk_rails_da0754aab3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_splits
    ADD CONSTRAINT fk_rails_da0754aab3 FOREIGN KEY (expense_item_id) REFERENCES public.expense_items(id);


--
-- Name: transactions fk_rails_e3b8660faa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_rails_e3b8660faa FOREIGN KEY (paid_by_id) REFERENCES public.users(id);


--
-- Name: item_splits fk_rails_e96af24616; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_splits
    ADD CONSTRAINT fk_rails_e96af24616 FOREIGN KEY (friendship_id) REFERENCES public.friendships(id);


--
-- PostgreSQL database dump complete
--

\unrestrict pbz87cofAYgvbQE57N3Uhmfy3lq8Kfhzx1oimpJ3qgtmsYau3259wRPE4gXRUne

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20210928010715'),
('20211006083940'),
('20260131051745'),
('20260131051841'),
('20260131063304'),
('20260131063313'),
('20260131063320'),
('20260131124905'),
('20260131184838');


