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
$Pasta = "C:\Users\Aluno\Desktop\opaopa\ef-core-project-base-generator"
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
# mkdir Models | cd
# foreach ($model in $models)
# {
# ni "$model.cs"
# "namespace $NomePrograma.Models;
# public class $model
# {
#     public Guid Id { get; set; }
# }" > "$model.cs"
# }

# # Criando o DBContext.cs
# ni "${NomePrograma}DBContext.cs"

# cd ../


# Funcao que gera as pastas models com os arquivos internos




# Funcao que gera os arquivos internos dos UseCases
function GeraArquivos {
    param (
        [Parameter(Mandatory=$true)]
        [string]$nomeUseCase,
        [string]$namespace
    )

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







