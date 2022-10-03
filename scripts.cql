// export all nodes to a CSV
MATCH (n)
WITH collect(n) AS all_nodes
CALL apoc.export.csv.data(all_nodes, [], "all-nodes.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data

// export all edges to a CSV
MATCH ()-[e]->()
WITH collect(e) AS all_edges
CALL apoc.export.csv.data([], all_edges, "all-edges.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data

// read from CSV file
USING PERIODIC COMMIT 1000 LOAD CSV FROM 'https://raw.githubusercontent.com/canbax/neo4j-data/main/movie-recommendations.csv' AS r
return r limit 5