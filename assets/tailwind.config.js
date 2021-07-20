module.exports = {
    purge: [
        "../**/*.html.eex",
        "../**/*.html.leex",
        "../**/views/**/*.ex",
        "../**/live/**/*.ex",
        "./js/**/*.js",
    ],
    darkMode: false, // or 'media' or 'class'
    theme: {
        fontFamily: {
          "branding": ["Krona One"],
          "username": ["Special Elite"]
        },
        extend: {},
    },
    variants: {
        extend: {},
    },
    plugins: [],
};