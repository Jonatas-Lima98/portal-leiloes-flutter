-- Portal de Leiloes
-- Migration 002: Cadastro de arrematantes

BEGIN;

CREATE TABLE public.arrematantes (
    id UUID PRIMARY KEY
        REFERENCES public.perfis(id)
        ON DELETE CASCADE,

    nome_completo VARCHAR(200) NOT NULL,

    rg VARCHAR(30) NOT NULL,

    orgao_expedidor VARCHAR(30) NOT NULL,

    cpf VARCHAR(11) NOT NULL UNIQUE,

    sexo VARCHAR(30),

    estado_civil VARCHAR(30),

    nacionalidade VARCHAR(100),

    data_nascimento DATE NOT NULL,

    nome_pai VARCHAR(200),

    nome_mae VARCHAR(200),

    profissao VARCHAR(100),

    telefone VARCHAR(20),

    celular VARCHAR(20) NOT NULL,

    telefone_recado VARCHAR(20),

    receber_informativos BOOLEAN NOT NULL
        DEFAULT FALSE,

    criado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    atualizado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    CONSTRAINT arrematantes_cpf_formato
        CHECK (cpf ~ '^[0-9]{11}$'),

    CONSTRAINT arrematantes_data_nascimento
        CHECK (data_nascimento <= CURRENT_DATE),

    CONSTRAINT arrematantes_nome_valido
        CHECK (
            CHAR_LENGTH(TRIM(nome_completo)) >= 3
        )
);

-- Ativa seguranca por linha
ALTER TABLE public.arrematantes
ENABLE ROW LEVEL SECURITY;

-- Remove permissoes diretas dos clientes
REVOKE ALL ON TABLE public.arrematantes
FROM PUBLIC, anon, authenticated;

-- Permite consulta por usuarios autenticados
GRANT SELECT ON TABLE public.arrematantes
TO authenticated;

-- Permite consultar somente o proprio cadastro
CREATE POLICY "Consultar proprio cadastro arrematante"
ON public.arrematantes
FOR SELECT
TO authenticated
USING (
    (SELECT auth.uid()) = id
);

-- Atualiza automaticamente a data de alteracao
CREATE TRIGGER trg_atualizar_arrematante
BEFORE UPDATE ON public.arrematantes
FOR EACH ROW
EXECUTE FUNCTION public.atualizar_data_perfil();

COMMIT;