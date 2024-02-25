function Todoloo.Utils.SplitStringArray(array, delimiter)
    delimiter = delimiter or ","
    return {strsplit(delimiter, array)}
end