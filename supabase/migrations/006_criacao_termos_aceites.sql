-- Portal de Leiloes
-- Migration 006: Termos e aceites

BEGIN;

-- Tipos de termos
CREATE TYPE public.tipo_termo AS ENUM (
    'termos_uso',
    'politica_privacidade',
    'regulamento_participacao',
    'contrato_adesao'
);

-- Tabela de versoes dos termos
CREATE TABLE public.termos (
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    tipo public.tipo_termo NOT NULL,

    titulo VARCHAR(200) NOT NULL,

    versao VARCHAR(30) NOT NULL,

    conteudo TEXT NOT NULL,

    obrigatorio BOOLEAN NOT NULL
        DEFAULT TRUE,

    ativo BOOLEAN NOT NULL
        DEFAULT FALSE,

    publicado_em TIMESTAMPTZ,

    criado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    CONSTRAINT termos_versao_unique
        UNIQUE (tipo, versao),

    CONSTRAINT termos_titulo_valido
        CHECK (
            CHAR_LENGTH(TRIM(titulo)) > 0
        ),

    CONSTRAINT termos_conteudo_valido
        CHECK (
            CHAR_LENGTH(TRIM(conteudo)) > 0
        ),

    CONSTRAINT termos_versao_valida
        CHECK (
            CHAR_LENGTH(TRIM(versao)) > 0
        ),

    CONSTRAINT termos_publicacao_valida
        CHECK (
            ativo = FALSE
            OR publicado_em IS NOT NULL
        )
);

-- Apenas uma versao ativa por tipo
CREATE UNIQUE INDEX termos_ativo_unique
ON public.termos (tipo)
WHERE ativo = TRUE;

-- Registro de aceites
CREATE TABLE public.aceites_termos (
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    perfil_id UUID NOT NULL
        REFERENCES public.perfis(id)
        ON DELETE RESTRICT,

    termo_id UUID NOT NULL
        REFERENCES public.termos(id)
        ON DELETE RESTRICT,

    aceito_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    CONSTRAINT aceites_termos_unique
        UNIQUE (perfil_id, termo_id)
);

-- Indice para consultas por termo
CREATE INDEX aceites_termo_idx
ON public.aceites_termos (termo_id);

-- Impede alteracao do conteudo publicado
CREATE FUNCTION public.proteger_termo_publicado()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    IF OLD.publicado_em IS NOT NULL THEN
        IF TG_OP = 'DELETE' THEN
            RAISE EXCEPTION
                'Termos publicados nao podem ser excluidos';
        END IF;

        IF NEW.tipo IS DISTINCT FROM OLD.tipo
        OR NEW.versao IS DISTINCT FROM OLD.versao
        OR NEW.titulo IS DISTINCT FROM OLD.titulo
        OR NEW.conteudo IS DISTINCT FROM OLD.conteudo
        OR NEW.obrigatorio IS DISTINCT FROM OLD.obrigatorio
        OR NEW.publicado_em IS DISTINCT FROM OLD.publicado_em
        OR NEW.id IS DISTINCT FROM OLD.id
        OR NEW.criado_em IS DISTINCT FROM OLD.criado_em
        THEN
            RAISE EXCEPTION
                'Crie uma nova versao do termo';
        END IF;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_proteger_termo_publicado
BEFORE UPDATE OR DELETE ON public.termos
FOR EACH ROW
EXECUTE FUNCTION public.proteger_termo_publicado();

-- Ativa seguranca por linha
ALTER TABLE public.termos
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.aceites_termos
ENABLE ROW LEVEL SECURITY;

-- Remove permissoes diretas
REVOKE ALL ON TABLE public.termos
FROM PUBLIC, anon, authenticated;

REVOKE ALL ON TABLE public.aceites_termos
FROM PUBLIC, anon, authenticated;

-- Permissoes de consulta
GRANT SELECT ON TABLE public.termos
TO anon, authenticated;

GRANT SELECT ON TABLE public.aceites_termos
TO authenticated;

-- Permite consultar termos publicados
CREATE POLICY "Consultar termos publicados"
ON public.termos
FOR SELECT
TO anon, authenticated
USING (
    publicado_em IS NOT NULL
    AND publicado_em <= NOW()
);

-- Cada usuario consulta seus proprios aceites
CREATE POLICY "Consultar proprios aceites"
ON public.aceites_termos
FOR SELECT
TO authenticated
USING (
    (SELECT auth.uid()) = perfil_id
);

COMMIT;