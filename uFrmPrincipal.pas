unit uFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Generics.Collections;

type
  TProva = class
    Codigo: Integer;
    Nome: string;
    Tipo: Char; // '-' para menor marca, '+' para maior marca
  end;

  TCidade = class
    Codigo: Integer;
    Nome: string;
    MedalhasOuro, MedalhasPrata, MedalhasBronze: Integer;
  end;

  TAtleta = class
    Codigo: Integer;
    Nome: string;
    Cidade: TCidade;
    Prova: TProva;
    Marca: Double;
    Posicao: Integer;
  end;

  TForm1 = class(TForm)
    MemoResultados: TMemo;
    btnExecutar: TButton;
    procedure btnExecutarClick(Sender: TObject);
  private
    procedure LerProvas;
    procedure LerCidades;
    function BuscarCidade(Cod: Integer): TCidade;
    function BuscarProva(Cod: Integer): TProva;
    procedure LerMarcas;
    procedure ProcessarResultados;
    procedure GerarArquivoResultado;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Provas: TObjectList<TProva>;
  Cidades: TObjectList<TCidade>;
  Atletas: TObjectList<TAtleta>;

implementation

{$R *.dfm}


procedure TForm1.btnExecutarClick(Sender: TObject);
begin
  Provas := TObjectList<TProva>.Create;
  Cidades := TObjectList<TCidade>.Create;
  Atletas := TObjectList<TAtleta>.Create;

  LerProvas;
  LerCidades;
  LerMarcas;
  ProcessarResultados;
  GerarArquivoResultado;

  Provas.Free;
  Cidades.Free;
  Atletas.Free;

  MemoResultados.Lines.Add('Processamento concluído. Resultados gravados em RESULTADOS.TXT');
end;

function TForm1.BuscarCidade(Cod: Integer): TCidade;
var
  C: TCidade;
begin
  for C in Cidades do
    if C.Codigo = Cod then
      Exit(C);
  Result := nil;
end;

function TForm1.BuscarProva(Cod: Integer): TProva;
var
  P: TProva;
begin
  for P in Provas do
    if P.Codigo = Cod then
      Exit(P);
  Result := nil;
end;

procedure TForm1.LerCidades;
var
  F: TextFile;
  Linha: string;
  C: TCidade;
begin
  AssignFile(F, 'C:\Desenv\TesteTotali\dados\CIDADES.TXT');
  Reset(F);
  while not Eof(F) do
  begin
    ReadLn(F, Linha);
    C := TCidade.Create;
    try
      C.Codigo := StrToInt(Copy(Linha, 1, 2));
      C.Nome := Trim(Copy(Linha, 3, 20));
      Cidades.Add(C);
    except
      on E: Exception do
        MemoResultados.Lines.Add('Erro ao ler linha. ' + Linha + #13#10 + E.Message);
    end;
  end;
  CloseFile(F);
end;

procedure TForm1.LerMarcas;
var
  F: TextFile;
  Linha: string;
  A: TAtleta;
begin
  AssignFile(F, 'C:\Desenv\TesteTotali\dados\MARCAS.TXT');
  Reset(F);
  while not Eof(F) do
  begin
    ReadLn(F, Linha);
    A := TAtleta.Create;

    try
      A.Codigo := StrToInt(Copy(Linha, 1, 5));
      A.Nome := Trim(Copy(Linha, 6, 40));
      A.Cidade := BuscarCidade(StrToInt(Copy(Linha, 46, 2)));
      A.Prova := BuscarProva(StrToInt(Copy(Linha, 48, 3)));
      A.Marca := StrToFloat(Copy(Linha, 51, 8));
      Atletas.Add(A);
    except
      on E: Exception do
        MemoResultados.Lines.Add('Erro ao ler linha. ' + Linha + #13#10 + E.Message);
    end;
  end;
  CloseFile(F);
end;

procedure TForm1.LerProvas;
var
  F: TextFile;
  Linha: string;
  P: TProva;
begin
  AssignFile(F, 'C:\Desenv\TesteTotali\dados\PROVAS.TXT');
  Reset(F);
  while not Eof(F) do
  begin
    ReadLn(F, Linha);
    P := TProva.Create;
    try
      P.Codigo := StrToInt(Copy(Linha, 1, 3));
      P.Nome := Trim(Copy(Linha, 4, 30));
      P.Tipo := Linha[34];
      Provas.Add(P);
    except
      on E: Exception do
        MemoResultados.Lines.Add('Erro ao ler linha. ' + Linha + #13#10 + E.Message);
    end;
  end;
  CloseFile(F);
end;

procedure OrdenarAtletas(Lista: TList<TAtleta>; TipoProva: Char);
var
  i, j: Integer;
  Temp: TAtleta;
begin
  for i := 0 to Lista.Count - 2 do
    for j := i + 1 to Lista.Count - 1 do
    begin
      if ((TipoProva = '-') and (Lista[i].Marca > Lista[j].Marca)) or
         ((TipoProva = '+') and (Lista[i].Marca < Lista[j].Marca)) then
      begin
        Temp := Lista[i];
        Lista[i] := Lista[j];
        Lista[j] := Temp;
      end;
    end;
end;

procedure TForm1.ProcessarResultados;
var
  P: TProva;
  Lista: TList<TAtleta>;
  i, Posicao: Integer;
begin
  for P in Provas do
  begin
    Lista := TList<TAtleta>.Create;
    for var A in Atletas do
      if A.Prova = P then
        Lista.Add(A);

    OrdenarAtletas(Lista, P.Tipo);

    Posicao := 1;
    for i := 0 to Lista.Count - 1 do
    begin
      if (i > 0) and (Lista[i].Marca <> Lista[i-1].Marca) then
        Posicao := i + 1;
      Lista[i].Posicao := Posicao;

      case Posicao of
        1: Inc(Lista[i].Cidade.MedalhasOuro);
        2: Inc(Lista[i].Cidade.MedalhasPrata);
        3: Inc(Lista[i].Cidade.MedalhasBronze);
      end;
    end;
    Lista.Free;
  end;
end;

procedure OrdenarCidades(Lista: TList<TCidade>);
var
  i, j: Integer;
  Temp: TCidade;
begin
  for i := 0 to Lista.Count - 2 do
    for j := i + 1 to Lista.Count - 1 do
    begin
      if (Lista[i].MedalhasOuro < Lista[j].MedalhasOuro) or
         ((Lista[i].MedalhasOuro = Lista[j].MedalhasOuro) and (Lista[i].MedalhasPrata < Lista[j].MedalhasPrata)) or
         ((Lista[i].MedalhasOuro = Lista[j].MedalhasOuro) and (Lista[i].MedalhasPrata = Lista[j].MedalhasPrata) and (Lista[i].MedalhasBronze < Lista[j].MedalhasBronze)) then
      begin
        Temp := Lista[i];
        Lista[i] := Lista[j];
        Lista[j] := Temp;
      end;
    end;
end;

procedure TForm1.GerarArquivoResultado;
var
  F: TextFile;
  CidadesOrdenadas: TList<TCidade>;
begin
  AssignFile(F, 'C:\Desenv\TesteTotali\dados\RESULTADOS.TXT');
  Rewrite(F);

  Writeln(F, 'Medalhistas:');
  for var A in Atletas do
    if A.Posicao in [1, 2, 3] then
      Writeln(F, Format('%s - %d - %s - %.4f - %s',
        [A.Prova.Nome, A.Posicao, A.Nome, A.Marca, A.Cidade.Nome]));

  Writeln(F, #13#10'Classificação por Cidade:');
  CidadesOrdenadas := TList<TCidade>.Create(Cidades);
  OrdenarCidades(CidadesOrdenadas);

  for var i := 0 to CidadesOrdenadas.Count - 1 do
    Writeln(F, Format('%d - %s - Ouro: %d, Prata: %d, Bronze: %d',
      [i+1, CidadesOrdenadas[i].Nome,
       CidadesOrdenadas[i].MedalhasOuro,
       CidadesOrdenadas[i].MedalhasPrata,
       CidadesOrdenadas[i].MedalhasBronze]));

  CidadesOrdenadas.Free;
  CloseFile(F);
end;

end.
