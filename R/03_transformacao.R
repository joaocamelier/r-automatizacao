# Conexão com banco SQL de dados brutos
sql_brutos <- conectar_sql(local = "dados/dados_brutos.db")

# Transforma conexão com objeto tibble com fonte externa
tbl_brutos <- dplyr::tbl(src = sql_brutos, from = "tbl_brutos")

# Trata tabela da DBNOMICS
dados_tratados <- tbl_brutos |>
  dplyr::select(
    "data" = "period",
    "pais" = "country",
    "variavel" = "indicator",
    "valor" = "value",
    "atualizacao" = "indexed_at"
    ) |>
  dplyr::collect() |>
  dplyr::mutate(
    variavel = dplyr::recode(
      .x = variavel,
      "FP.CPI.TOTL.ZG" = "Inflação (anual, %)",
      "FR.INR.DPST" = "Juros (depósito, %)",
      "NY.GDP.MKTP.KD.ZG" = "PIB (cresc. anual, %)",
      "PA.NUS.FCRF" = "Câmbio (média, UMC/US$)",
      "SL.UEM.TOTL.NE.ZS" = "Desemprego (total, %)"
      ),
    pais = countrycode::countrycode(
      sourcevar   = pais,
      origin      = "iso3c",
      destination = "country.name"
      ),
    atualizacao = lubridate::as_date(atualizacao)
    ) |>
  tidyr::drop_na() |>
  dplyr::as_tibble()

# Criar banco de dados SQL
sql_tratados <- conectar_sql(local = "dados/dados_tratados.db")

# Armazenar dados em tabela no banco SQL
DBI::dbWriteTable(
    conn = sql_tratados,
    name = "tbl_tratados",
    value = dados_tratados,
    overwrite = TRUE
)
  
# Encerrar conexão
DBI::dbDisconnect(conn = sql_brutos)
DBI::dbDisconnect(conn = sql_tratados)
