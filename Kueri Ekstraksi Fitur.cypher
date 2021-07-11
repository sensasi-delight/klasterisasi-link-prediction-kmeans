// 1. Impor Dataset Menjadi Node Caleg
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/sensasi-delight/klasterisasi-link-prediction-kmeans/main/dataset/d2%20-%20Dataset%20Hasil%20Praproses.csv" as csvcaleg FIELDTERMINATOR ';'
create (:Caleg {
	nama: csvcaleg.nama,
  partai: csvcaleg.partai,
  dapil: csvcaleg.dapil
});



// 2. Pembuatan Node Partai dan Dapil
MATCH (n:Caleg) WITH DISTINCT n.partai as namapartai
CREATE  (:Partai {nama: namapartai});

MATCH (n:Caleg) WITH DISTINCT n.dapil as namadapil
CREATE  (:Dapil {nama: namadapil});



// 3. Pembuatan Edge/Relationship ANGGOTA dan DI_DAPIL
MATCH
  (a:Caleg),
  (b:Partai)
WHERE a.partai = b.nama
CREATE (a)-[r:ANGGOTA]->(b);

MATCH
  (a:Caleg),
  (b:Dapil)
WHERE a.dapil = b.nama
CREATE (a)-[r:DI_DAPIL]->(b);



// 4. Ekstraksi Fitur dan Ekspor Menjadi Berkas CSV
WITH "
  MATCH
    (c1:Caleg),
    (c2:Caleg)
  WHERE ID(c1) < ID(c2)
  RETURN 
    c1.nama as node1,
    c2.nama as node2,
    gds.alpha.linkprediction.commonNeighbors(c1, c2) as cn,
    gds.alpha.linkprediction.preferentialAttachment(c1, c2) as pa,
    gds.alpha.linkprediction.totalNeighbors(c1, c2) as tn,
    gds.alpha.linkprediction.sameCommunity(c1, c2, \"labelPropogation\") AS sp,
    gds.alpha.linkprediction.sameCommunity(c1, c2, \"louvain\") AS sl
" as query
CALL apoc.export.csv.query(query, "d3 - Dataset Hasil Ekstraksi Fitur.csv", {})
YIELD file
return file;