import string

def preprocess_text(text):
    """
    Preprocess the text by converting it to lowercase, removing punctuation, and splitting into words.
    """
    # Convert text to lowercase
    text = text.lower()
    
    # Remove punctuation
    text = text.translate(str.maketrans("", "", string.punctuation))
    
    # Split text into words (tokenize)
    words = text.split()
    
    return set(words)

def compare_texts(file1, file2):
    """
    Compare two text files and count the number of unique words in the first file that are not in the second.
    """
    # Open and read the contents of both files
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        text1 = f1.read()
        text2 = f2.read()

    # Preprocess both texts
    words1 = preprocess_text(text1)
    words2 = preprocess_text(text2)

    # Find the unique words in the first text that are not in the second
    unique_words = words1 - words2
    
    # Count the number of unique words
    unique_count = len(unique_words)
    
    # Display the unique words and their count
    print(f"Number of unique words in {file1} that are not in {file2}: {unique_count}")
    print("Unique words:", list(unique_words)[:10])

# Specify the file paths
file1 = "en-sv/TED2020/raw/test.en"
file2 = "en-sv/infopankki/raw/train.en"

# Call the function to compare the texts
compare_texts(file1, file2)