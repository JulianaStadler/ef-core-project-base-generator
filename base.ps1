<#-------------- COMO USAR -----------------
1 - Mova os arquivos (base.ps1, models.json, usecases.json)
para a mesma pasta e coloque a url dessa pasta na
variavel $PastaPrograma
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
pode tirar a pasta e usar o programa pre escrito normalmente. Caso 
o código nao esteja funcionando execute no powershell como admin:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
E em seguida selecione A
6 - Pelo terminal acesse o caminho da pasta e crie a variavel
de ambiente para acessar o banco de dados

Nota: depois de criado voce pode excluir normalmente este programa
de execucao
------------------------------------------#>

echo "Iniciando criacao"

# Pasta onde foi salvo os 3 arquivos, PRECISA TERMINAR COM \
$PastaPrograma = "C:\Users\Aluno\Desktop\opaopa\ef-core-project-base-generator"
$NomePrograma = "PastaCriacao"

# Entra no caminho da pasta
cd $PastaPrograma

# Salva models e use cases em variaveis
$models = cat models.json -Raw | ConvertFrom-Json
$usecases = cat usecases.json -Raw | ConvertFrom-Json



echo "criando o programa $NomePrograma"
mkdir $NomePrograma | cd

dotnet new web
dotnet new gitignore
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.SqlServer

"using System.Data;
using System.Text.RegularExpressions;
using ${NomePrograma}.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.SqlServer;
using Microsoft.EntityFrameworkCore.Design;" > Program.cs



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

"using Microsoft.EntityFrameworkCore;
namespace ${NomePrograma}.Models;
public class ${NomePrograma}DbContext(DbContextOptions options) : DbContext(options)
{" > "${NomePrograma}DBContext.cs"

foreach ($model in $models)
{
"    public DbSet<${model}> ${model}s => Set<${model}>();" >> "${NomePrograma}DBContext.cs"
}

"
    protected override void OnModelCreating(ModelBuilder model)
    {" >> "${NomePrograma}DBContext.cs"

foreach ($model in $models)
{
"        model.Entity<${model}>();" >> "${NomePrograma}DBContext.cs"
}

"   }
}" >> "${NomePrograma}DBContext.cs"


cd ..






# Funcao que gera os arquivos internos dos UseCases
function GeraArquivos {
    param (
        [Parameter(Mandatory=$true)]
        [string]$nomeUseCase,
        [string]$namespace
    )

    # Salva os namespaces no program.cs
    $caminhoAtual = pwd
    cd "${PastaPrograma}/${NomePrograma}"
    "using $namespace;" >> Program.cs
    cd $caminhoAtual

# criando payload
ni "${nomeUseCase}Payload.cs"
"namespace ${namespace};
using System.ComponentModel.DataAnnotations;

public record ${nomeUseCase}Payload
{

}" > "${nomeUseCase}Payload.cs"


# criando response
ni "${nomeUseCase}Response.cs"
"namespace ${namespace};

public record ${nomeUseCase}Response;" > "${nomeUseCase}Response.cs"


# criando use case
ni "${nomeUseCase}UseCase.cs"
"namespace ${namespace};

public record ${nomeUseCase}UseCase
{
    public async Task<Result<${nomeUseCase}Response>> Do(${nomeUseCase}Payload payload)
    {
        return Result<${nomeUseCase}Response>.Success(null);
    }
}" > "${nomeUseCase}UseCase.cs"
   
}





# Funcao que gera as pastas dos UseCases com base no arquivo usecases.json
function GeraPastas {
    param (
        [Parameter(Mandatory=$true)]
        [object]$obj,
        [string]$namespace = "${NomePrograma}.UseCases"
    )


    # esse objeto tem chaves? ex {}
    if ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])) {
        foreach ($item in $obj) {
            mkdir $item | cd
            $namespaceNova = "$namespace.$item"
            GeraPastas -obj $item -namespace $namespaceNova
            cd ..
        }
    }
    # esse item e uma lista? ex []
    elseif ($obj -is [PSCustomObject] -or $obj -is [Hashtable]) {
        foreach ($Case in $obj.PSObject.Properties) {
            # se for para o use case ficar solto dentro da pasta UseCases
            if ($Case.Name -eq "Soltos"){
                GeraPastas -obj $Case.Value -namespace $namespace
            } else {
                mkdir $Case.Name | cd
                $namespaceNova = "$namespace.$($Case.Name)"
                GeraPastas -obj $Case.Value -namespace $namespaceNova
                cd ..
            }

        }
    }
    # somente um item comum, ex ""
    else {
        GeraArquivos -nomeUseCase $obj -namespace $namespace
    }
}

mkdir UseCases | cd
GeraPastas -obj $UseCases
cd ..

ni Result.cs
"namespace ${NomePrograma};

public record Result<T>(
    T Data,
    bool IsSuccess,
    string Reason
)
{
    public static Result<T> Success(T data)
        => new(data, true, null);
    
    public static Result<T> Fail(string reason)
        => new(default, false, reason);
}" > Result.cs


# Criando conexao com o banco de dados
"
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<${NomePrograma}DbContext>(options => {
    var sqlConn = Environment.GetEnvironmentVariable(`"SQL_CONNECTION`");
    options.UseSqlServer(sqlConn);
});

var app = builder.Build();

app.Run();" >> program.cs



# Para sair da pasta criada
cd ..