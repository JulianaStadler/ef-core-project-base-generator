<#-------------- COMO USAR -----------------
1 - Mova os arquivos (base.ps1, models.json, usecases.json)
para a mesma pasta e coloque a url dessa pasta na
variavel $Pasta
2 - Coloque o nome do programa que quer criar em $NomePrograma
3 - Escreva dentro do arquivo models.json o nome dos models em
formato json e nao criar o dbcontext pois vai ser criado pelo
arquivo base.ps1
4 - Escreva dentro do arquivo usecases.json os use cases
que quer criar, sendo que, o codigo base vai criar os payloads,
response e os usecases entao, dentro do arquivo usecases,
escreva o nome de cada use case, caso queira que essa pasta 
com os arquivos esteja dentro de outra pasta apenas escreva
dentro do json o nome da pasta com os arquivos dentro
5 - Execute o programa base.ps1, ao terminar a execucao
pode tirar a pasta e usar o programa pre escrito normalmente
------------------------------------------#>

echo "Iniciando criacao"

# Pasta onde foi salvo os 3 arquivos, PRECISA TERMINAR COM \
$Pasta = "C:\Users\Aluno\Desktop\Nova pasta\"
$NomePrograma = "PastaCriacao"

# Entra no caminho da pasta
cd $Pasta

# Salva models e use cases em variaveis
$models = cat models.json -Raw | ConvertFrom-Json
$usecases = cat usecases.json -Raw | ConvertFrom-Json



echo "criando o programa $NomePrograma"
# mkdir $NomePrograma | cd
# dotnet new web
# dotnet new gitignore

# Criando a pasta models e os Models
mkdir Models | cd
foreach ($model in $models)
{
ni "$model.cs"
"namespace $NomePrograma.Models;
public class $model
{
    public Guid Id { get; set; }
}" > "$model.cs"
}

# Criando o DBContext.cs
ni "${NomePrograma}DBContext.cs"


cd ../

# Funcao que gera as pastas models com os arquivos internos



# Ler cada linha do arquivo models
# for /f "usebackq tokens=* delims=" %%A in ("%arquivo%") do (
#     set "linha=%%A"
#     echo Linha: !linha!
# )

