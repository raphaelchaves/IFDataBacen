#---------------------------------------------------------------------------------------
#Objetivo: Efetuar a captura e o parsing dos dados de todas as IFs do Sistema Finaceiro Nacional
#---------------------------------------------------------------------------------------

#Fonte: Banco Central do Brasil (IF Data - Dados Trimestrais

#Formato de Entrada: JSON (JavaScript Object Notation)

#Formato de Saída: 3 Arquivos CSV
#a) IF_Data_Contas_Cosif.csv: Arquivo que contempla o cadastro das contas do COSIF
#b) IF_Data_Cadastro_1005.csv: Arquivo que contempla o cadastro das IFs
#c) IF_Data_ConglPrude_IfsInde.csv: Arquivo que contempla os dados financeiros

#Desenvolvido por: Raphael Franco Chaves

#---------------------------------------------------------------------------------------

#Informe e data início e fim
$DateStart = '2020-06-01'
$DateEnd = '2020-09-01'

#Informe o diretório de saída onde os arquivos csv serão salvos
$folderPath = 'C:\Temp\DadosAbertos\'

$Begin = [datetime] $DateStart
$End   = [datetime] $DateEnd

#Calcula quantidade de meses entre a data início e fim para executar o loop
$Monthdiff = $End.month - $Begin.month + (($End.Year - $Begin.year) * 12)

#Inicia o loop
foreach ($DC_Item in 0..$Monthdiff){
    
$Asofdate = $Begin.AddMonths($DC_Item).ToString('yyyyMM')

$Month = $Begin.AddMonths($DC_Item).ToString('MM')

#Considera apenas trimestres (IF data do Bacen disponibiliza apenas informações trimestrais
if($Month -eq '03' -or $Month -eq '06' -or $Month -eq '09' -or $Month -eq '12'){
    
#URL do Bacen contendo o cadastro da cada conta
$URL_Info = "https://www3.bcb.gov.br/ifdata/rest/arquivos?nomeArquivo="+($Asofdate)+"/info"+($Asofdate)+".json&{}"

#Efetua a chamada da API
$Raw_URL_Info  = Invoke-WebRequest -Uri $URL_Info

#Remove BOM (byte-order-mark) do JSON
$Char_Resp_Info  = [System.IO.StreamReader]::new($Raw_URL_Info.RawContentStream).ReadToEnd()
$Json_Final_Info = ConvertFrom-Json -InputObject $Char_Resp_Info

#URL do Bacen contendo dados cadastrais dos Conglomerados Prudenciais e Instituições Indenpendentes
$URL_cadastro_1005 = "https://www3.bcb.gov.br/ifdata/rest/arquivos?nomeArquivo="+($Asofdate)+"/cadastro"+($Asofdate)+"_1005.json&{}"

#Efetua a chamada da API
$Raw_URL_cadastro_1005  = Invoke-WebRequest -Uri $URL_cadastro_1005

#Remove BOM (byte-order-mark) do JSON
$Char_Resp_cadastro_1005  = [System.IO.StreamReader]::new($Raw_URL_cadastro_1005.RawContentStream).ReadToEnd()
$Json_Final_cadastro_1005 = ConvertFrom-Json -InputObject $Char_Resp_cadastro_1005

#URL do Bacen contendo dados Conglomerado Prudencial
$URL_Dados_1 = "https://www3.bcb.gov.br/ifdata/rest/arquivos?nomeArquivo="+($Asofdate)+"/dados"+($Asofdate)+"_1.json&{}"

#Efetua a chamada da API
$Raw_URL_Dados_1  = Invoke-WebRequest -Uri $URL_Dados_1

#Remove BOM (byte-order-mark) do JSON
$Char_Resp_Dados_1  = [System.IO.StreamReader]::new($Raw_URL_Dados_1.RawContentStream).ReadToEnd()
$Json_Final_Dados_1 = ConvertFrom-Json -InputObject $Char_Resp_Dados_1

#URL do Bacen contendo dados Conglomerado Financeiro e Instituições Independentes
$URL_Dados_2 = "https://www3.bcb.gov.br/ifdata/rest/arquivos?nomeArquivo="+($Asofdate)+"/dados"+($Asofdate)+"_2.json&{}"

#Efetua a chamada da API
$Raw_URL_Dados_2  = Invoke-WebRequest -Uri $URL_Dados_2

#Remove BOM (byte-order-mark) do JSON
$Char_Resp_Dados_2  = [System.IO.StreamReader]::new($Raw_URL_Dados_2.RawContentStream).ReadToEnd()
$Json_Final_Dados_2 = ConvertFrom-Json -InputObject $Char_Resp_Dados_2


#URL do Bacen contendo dados de Instituições Individuais
$URL_Dados_3 = "https://www3.bcb.gov.br/ifdata/rest/arquivos?nomeArquivo="+($Asofdate)+"/dados"+($Asofdate)+"_3.json&{}"

#Efetua a chamada da API
$Raw_URL_Dados_3  = Invoke-WebRequest -Uri $URL_Dados_3

#Remove BOM (byte-order-mark) do JSON
$Char_Resp_Dados_3  = [System.IO.StreamReader]::new($Raw_URL_Dados_3.RawContentStream).ReadToEnd()
$Json_Final_Dados_3 = ConvertFrom-Json -InputObject $Char_Resp_Dados_3

#URL do Bacen contendo dados de Instituições com Operações de Câmbio
$URL_Dados_4 = "https://www3.bcb.gov.br/ifdata/rest/arquivos?nomeArquivo="+($Asofdate)+"/dados"+($Asofdate)+"_4.json&{}"

#Efetua a chamada da API
$Raw_URL_Dados_4  = Invoke-WebRequest -Uri $URL_Dados_4

#Remove BOM (byte-order-mark) do JSON
$Char_Resp_Dados_4  = [System.IO.StreamReader]::new($Raw_URL_Dados_4.RawContentStream).ReadToEnd()
$Json_Final_Dados_4 = ConvertFrom-Json -InputObject $Char_Resp_Dados_4



#Efetua o parsing do dados disponíveis no Json
$Contas = $Json_Final_Info | foreach {

     $_ | foreach {
        [pscustomobject]@{ 
         Data = $Asofdate
           id = $_.id
            n = $_.n            
           ni = $_.ni
            d = $_.d
           di = $_.di
            a = $_.a
           td = $_.td
          lid = $_.lid
           ty = $_.ty
            }
          }
        }

#Exporta dados para arquivo no formato CSV
$Contas | Export-Csv ($folderPath + $Asofdate + "_IF_Data_Contas_Cosif.csv") -Append -NoTypeInformation -Encoding UTF8


#Efetua o parsing do dados disponíveis no Json
$Cadastro_1005 = $Json_Final_cadastro_1005 | foreach {

     $_ | foreach {
        [pscustomobject]@{ 
         Data = $Asofdate
            c0 = $_.c0
            c1 = $_.c1
            c2 = $_.c2
            c3 = $_.c3
            c4 = $_.c4
            c5 = $_.c5
            c6 = $_.c6
            c7 = $_.c7
            c8 = $_.c8
            c9 = $_.c9
           c10 = $_.c10
           c11 = $_.c11
           c12 = $_.c12
           c13 = $_.c13
           c14 = $_.c14
           c15 = $_.c15
           c16 = $_.c16
           c17 = $_.c17
           c18 = $_.c18
           c19 = $_.c19
           c20 = $_.c20
           c21 = $_.c21
           c22 = $_.c22
           c23 = $_.c23
           c24 = $_.c24
           c25 = $_.c25
           c26 = $_.c26
           c27 = $_.c27
           c28 = $_.c28
           c29 = $_.c29
           c30 = $_.c30
            }
          }
        }

#Exporta dados para arquivo no formato CSV
$Cadastro_1005 | Export-Csv ($folderPath + $Asofdate + "_IF_Data_Cadastro.csv") -Append -NoTypeInformation -Encoding UTF8


#Efetua o parsing do dados disponíveis no Json
$Dados_1_Attr = $Json_Final_Dados_1.values | foreach {   

     $cnpj = $_.e     
     $_.v | foreach {
        [pscustomobject]@{
            Data = $Asofdate
              Id = 1
              If = 'Conglomerados Prudenciais e Instituições Independentes'
            Cnpj = $cnpj
            ContaCosif = $_.i
            Valor = $_.v
            }
           }
          }

#Exporta dados para arquivo no formato CSV
$Dados_1_Attr | Export-Csv ($folderPath + $Asofdate + "_Id1_IF_Data_Valores_Ifs.csv") -Append -NoTypeInformation -Encoding UTF8

#Efetua o parsing do dados disponíveis no Json
$Dados_2_Attr = $Json_Final_Dados_2.values | foreach {   

     $cnpj = $_.e     
     $_.v | foreach {
        [pscustomobject]@{
            Data = $Asofdate
              Id = 2
              If = 'Conglomerados Financeiros e Instituições Independentes'
            Cnpj = $cnpj
            ContaCosif = $_.i
            Valor = $_.v
            }
           }
          }

#Exporta dados para arquivo no formato CSV
$Dados_2_Attr | Export-Csv ($folderPath + $Asofdate + "_Id2_IF_Data_Valores_Ifs.csv") -Append -NoTypeInformation -Encoding UTF8

#Efetua o parsing do dados disponíveis no Json
$Dados_3_Attr = $Json_Final_Dados_3.values | foreach {   

     $cnpj = $_.e     
     $_.v | foreach {
        [pscustomobject]@{
            Data = $Asofdate
              Id = 3
              If = 'Instituições Individuais'
            Cnpj = $cnpj
            ContaCosif = $_.i
            Valor = $_.v
            }
           }
          }

#Exporta dados para arquivo no formato CSV
$Dados_3_Attr | Export-Csv ($folderPath + $Asofdate + "_Id3_IF_Data_Valores_Ifs.csv") -Append -NoTypeInformation -Encoding UTF8

#Efetua o parsing do dados disponíveis no Json
$Dados_4_Attr = $Json_Final_Dados_4.values | foreach {   

     $cnpj = $_.e     
     $_.v | foreach {
        [pscustomobject]@{
            Data = $Asofdate
              Id = 4
              If = 'Instituições com Operações de Câmbio'
            Cnpj = $cnpj
            ContaCosif = $_.i
            Valor = $_.v
            }
           }
          }

#Exporta dados para arquivo no formato CSV
$Dados_4_Attr | Export-Csv ($folderPath + $Asofdate + "_Id4_IF_Data_Valores_Ifs.csv") -Append -NoTypeInformation -Encoding UTF8

 }
}
