-- Portal de Leiloes
-- Migration 001: Estrutura inicial de perfis

BEGIN;

-- Tipos de usuarios
CREATE TYPE public.tipo_usuario AS ENUM (
    'arrematante',
    'leiloeiro',
    'administrador'
);

-- Situacoes cadastrais
CREATE TYPE public.status_usuario AS ENUM (
    'pendente',
    'em_analise',
    'aprovado',
    'reprovado',
    'suspenso'
);

-- Tabela principal de perfis
CREATE TABLE public.perfis (
    id UUID PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    login VARCHAR(50) NOT NULL,

    tipo public.tipo_usuario NOT NULL
        DEFAULT 'arrematante',

    status public.status_usuario NOT NULL
        DEFAULT 'pendente',

    criado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    atualizado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    CONSTRAINT login_formato CHECK (
        login ~ '^[a-zA-Z0-9_.]{3,50}$'
    )
);

-- Impede nomes de usuario duplicados
CREATE UNIQUE INDEX perfis_login_unique
ON public.perfis (LOWER(login));

-- Ativa seguranca por linha
ALTER TABLE public.perfis
ENABLE ROW LEVEL SECURITY;

-- Remove permissoes diretas dos clientes
REVOKE ALL ON TABLE public.perfis
FROM PUBLIC, anon, authenticated;

-- Permite leitura para usuarios autenticados
GRANT SELECT ON TABLE public.perfis
TO authenticated;

-- Cada usuario pode consultar apenas seu perfil
CREATE POLICY "Consultar proprio perfil"
ON public.perfis
FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) = id);

-- Atualiza automaticamente a data de alteracao
CREATE FUNCTION public.atualizar_data_perfil()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_atualizar_perfil
BEFORE UPDATE ON public.perfis
FOR EACH ROW
EXECUTE FUNCTION public.atualizar_data_perfil();

COMMIT;