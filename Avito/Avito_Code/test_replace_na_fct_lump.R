df <- tibble(x = c(1, 2, NA), y = c("a", NA, "b"), z = list(1:5, NULL, 10:20))
df %>% replace_na(list(x = 0, y = "unknown"))

# NULL are the list-col equivalent of NAs
df %>% replace_na(list(z = list(5)))

df$x %>% replace_na(0)
df$y %>% replace_na("unknown")


x <- factor(rep(LETTERS[1:9], times = c(40, 10, 5, 27, 1, 1, 1, 1, 1)))
x %>% table()
x %>% fct_lump() %>% table()
x %>% fct_lump(prop = 0.1) %>% table()
x %>% fct_lump(prop = 0.2) %>% table()
x %>% fct_lump(prop = 0.3) %>% table()
x %>% fct_lump(prop = 0.5) %>% table()
x %>% fct_lump(prop = 0.05) %>% table()
x %>% fct_lump() %>% fct_inorder() %>% table()

x <- factor(letters[rpois(100, 5)])
x
table(x)
table(fct_lump(x))
table(fct_lump(x, prop = 0.1))
# Use positive values to collapse the rarest
fct_lump(x, n = 3)
fct_lump(x, prop = 0.1)

# Use negative values to collapse the most common
fct_lump(x, n = -3)
fct_lump(x, prop = -0.1)

# Use weighted frequencies
w <- c(rep(2, 50), rep(1, 50))
fct_lump(x, n = 5, w = w)

# Use ties.method to control how tied factors are collapsed
fct_lump(x, n = 6)
fct_lump(x, n = 6, ties.method = "max")
