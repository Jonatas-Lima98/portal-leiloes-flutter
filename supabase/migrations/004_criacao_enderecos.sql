-- Portal de Leiloes
-- Migration 004: Cadastro de enderecos

BEGIN;

-- Tipos de endereco
CREATE TYPE public.tipo_endereco AS ENUM (
    'residencial',
    'comercial',
    'correspondencia'
);

-- Tabela de enderecos
CREATE TABLE public.enderecos (
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    perfil_id UUID NOT NULL
        REFERENCES public.perfis(id)
        ON DELETE CASCADE,

    tipo_endereco public.tipo_endereco NOT NULL
        DEFAULT 'residencial',

    cep VARCHAR(8) NOT NULL,

    logradouro VARCHAR(200) NOT NULL,

    numero VARCHAR(20) NOT NULL,

    complemento VARCHAR(150),

    bairro VARCHAR(100) NOT NULL,

    cidade VARCHAR(100) NOT NULL,

    estado VARCHAR(2) NOT NULL,

    pais VARCHAR(60) NOT NULL
        DEFAULT 'Brasil',

    principal BOOLEAN NOT NULL
        DEFAULT FALSE,

    criado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    atualizado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    CONSTRAINT enderecos_cep_formato
        CHECK (cep ~ '^[0-9]{8}$'),

    CONSTRAINT enderecos_estado_valido
        CHECK (
            estado IN (
                'AC', 'AL', 'AP', 'AM', 'BA',
                'CE', 'DF', 'ES', 'GO', 'MA',
                'MT', 'MS', 'MG', 'PA', 'PB',
                'PR', 'PE', 'PI', 'RJ', 'RN',
                'RS', 'RO', 'RR', 'SC', 'SP',
                'SE', 'TO'
            )
        ),

    CONSTRAINT enderecos_pais_valido
        CHECK (pais = 'Brasil'),

    CONSTRAINT enderecos_campos_validos
        CHECK (
            CHAR_LENGTH(TRIM(logradouro)) > 0
            AND CHAR_LENGTH(TRIM(numero)) > 0
            AND CHAR_LENGTH(TRIM(bairro)) > 0
            AND CHAR_LENGTH(TRIM(cidade)) > 0
        )
);

-- Melhora consultas por perfil
CREATE INDEX enderecos_perfil_idx
ON public.enderecos (perfil_id);

-- Permite apenas um endereco principal por perfil
CREATE UNIQUE INDEX enderecos_principal_unique
ON public.enderecos (perfil_id)
WHERE principal = TRUE;

-- Ativa seguranca por linha
ALTER TABLE public.enderecos
ENABLE ROW LEVEL SECURITY;

-- Remove permissoes diretas dos clientes
REVOKE ALL ON TABLE public.enderecos
FROM PUBLIC, anon, authenticated;

-- Permite consulta por usuarios autenticados
GRANT SELECT ON TABLE public.enderecos
TO authenticated;

-- Permite consultar somente os proprios enderecos
CREATE POLICY "Consultar proprios enderecos"
ON public.enderecos
FOR SELECT
TO authenticated
USING (
    (SELECT auth.uid()) = perfil_id
);

-- Atualiza automaticamente a data de alteracao
CREATE TRIGGER trg_atualizar_endereco
BEFORE UPDATE ON public.enderecos
FOR EACH ROW
EXECUTE FUNCTION public.atualizar_data_perfil();

COMMIT;