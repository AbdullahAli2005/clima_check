String getWeatherMessage({
  double? precipitation,
  double? humidity,
  double? windSpeed,
  double? pressure,
}) {
  if (precipitation != null) {
    if (precipitation == 0) {
      return "Currently no precipitation.";
    } else if (precipitation > 0 && precipitation <= 2.5) {
      return "Light rain expected.";
    } else if (precipitation > 2.5 && precipitation <= 7.6) {
      return "Moderate rain showers ongoing.";
    } else {
      return "Heavy rain falling.";
    }
  }

  if (humidity != null) {
    if (humidity <= 30) {
      return "Air feels dry.";
    } else if (humidity <= 60) {
      return "Moderate humidity in the air.";
    } else if (humidity <= 80) {
      return "Humidity is quite high.";
    } else {
      return "Very humid conditions.";
    }
  }

  if (windSpeed != null) {
    if (windSpeed <= 5) {
      return "Calm wind.";
    } else if (windSpeed <= 15) {
      return "Light breeze.";
    } else if (windSpeed <= 30) {
      return "Moderate wind blowing.";
    } else {
      return "Strong winds in the area.";
    }
  }

  if (pressure != null) {
    if (pressure < 1000) {
      return "Low pressure, possible weather changes.";
    } else if (pressure <= 1015) {
      return "Normal pressure, stable weather.";
    } else {
      return "High pressure, clear skies ahead.";
    }
  }

  return ""; // Default message if nothing is passed
}
