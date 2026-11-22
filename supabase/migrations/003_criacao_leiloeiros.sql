-- Portal de Leiloes
-- Migration 003: Cadastro de leiloeiros

BEGIN;

CREATE TABLE public.leiloeiros (
    id UUID PRIMARY KEY
        REFERENCES public.perfis(id)
        ON DELETE CASCADE,

    nome_completo VARCHAR(200) NOT NULL,

    cpf VARCHAR(11) NOT NULL UNIQUE,

    rg VARCHAR(30),

    orgao_expedidor VARCHAR(30),

    matricula_junta_comercial VARCHAR(50) NOT NULL,

    uf_junta_comercial VARCHAR(2) NOT NULL,

    telefone VARCHAR(20),

    celular VARCHAR(20) NOT NULL,

    telefone_recado VARCHAR(20),

    possui_empresa BOOLEAN NOT NULL
        DEFAULT FALSE,

    cnpj VARCHAR(14) UNIQUE,

    razao_social VARCHAR(200),

    nome_fantasia VARCHAR(200),

    receber_informativos BOOLEAN NOT NULL
        DEFAULT FALSE,

    criado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    atualizado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    CONSTRAINT leiloeiros_cpf_formato
        CHECK (cpf ~ '^[0-9]{11}$'),

    CONSTRAINT leiloeiros_cnpj_formato
        CHECK (
            cnpj IS NULL
            OR cnpj ~ '^[0-9]{14}$'
        ),

    CONSTRAINT leiloeiros_nome_valido
        CHECK (
            CHAR_LENGTH(TRIM(nome_completo)) >= 3
        ),

    CONSTRAINT leiloeiros_uf_valida
        CHECK (
            uf_junta_comercial IN (
                'AC', 'AL', 'AP', 'AM', 'BA',
                'CE', 'DF', 'ES', 'GO', 'MA',
                'MT', 'MS', 'MG', 'PA', 'PB',
                'PR', 'PE', 'PI', 'RJ', 'RN',
                'RS', 'RO', 'RR', 'SC', 'SP',
                'SE', 'TO'
            )
        ),

    CONSTRAINT leiloeiros_matricula_valida
        CHECK (
            CHAR_LENGTH(
                TRIM(matricula_junta_comercial)
            ) > 0
        ),

    CONSTRAINT leiloeiros_matricula_unique
        UNIQUE (
            matricula_junta_comercial,
            uf_junta_comercial
        ),

    CONSTRAINT leiloeiros_dados_empresa
        CHECK (
            (
                possui_empresa = FALSE
                AND cnpj IS NULL
                AND razao_social IS NULL
                AND nome_fantasia IS NULL
            )
            OR
            (
                possui_empresa = TRUE
                AND cnpj IS NOT NULL
                AND razao_social IS NOT NULL
                AND CHAR_LENGTH(
                    TRIM(razao_social)
                ) > 0
            )
        )
);

-- Ativa seguranca por linha
ALTER TABLE public.leiloeiros
ENABLE ROW LEVEL SECURITY;

-- Remove permissoes diretas dos clientes
REVOKE ALL ON TABLE public.leiloeiros
FROM PUBLIC, anon, authenticated;

-- Permite consulta por usuarios autenticados
GRANT SELECT ON TABLE public.leiloeiros
TO authenticated;

-- Permite consultar somente o proprio cadastro
CREATE POLICY "Consultar proprio cadastro leiloeiro"
ON public.leiloeiros
FOR SELECT
TO authenticated
USING (
    (SELECT auth.uid()) = id
);

-- Atualiza automaticamente a data de alteracao
CREATE TRIGGER trg_atualizar_leiloeiro
BEFORE UPDATE ON public.leiloeiros
FOR EACH ROW
EXECUTE FUNCTION public.atualizar_data_perfil();

COMMIT;