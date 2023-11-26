package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func main() {
	// Read the artifact-spec.json file
	filePath := "build/artifact-spec.json"
	data, err := os.ReadFile(filePath)

	if err != nil {
		fmt.Printf("Error reading file %s\n", filePath)
		panic(err)
	} else {
		// Merge the data with { "foo": "bar" }
		var mergedData map[string]interface{}
		err = json.Unmarshal(data, &mergedData)
		if err != nil {
			panic(err)
		}

		count, ok := mergedData["count"].(float64)

		if !ok {
			count = 0
		}

		mergedData["count"] = count + 1

		fmt.Printf("Merged data: %v\n", mergedData)
		// Write the merged data back to artifactory-spec.json
		outputData, err := json.Marshal(mergedData)
		if err != nil {
			panic(err)
		}

		fmt.Printf("Writing %s %s\n", filePath, outputData)
		err = os.WriteFile(filePath, outputData, 0644)
		if err != nil {
			panic(err)
		}
	}
}
