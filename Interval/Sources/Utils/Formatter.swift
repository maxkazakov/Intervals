import Foundation

public class Formatter {
//    static func formatDistance(meters: Double) -> String {
//
//    }
}

public extension Int {
    func formatMilliseconds() -> String {
        let totalSeconds = self / 1000

        let hours = totalSeconds / 60 / 60
        let minutes = totalSeconds / 60 % 60
        let seconds = totalSeconds % 60
        let ms = self % 1000 / 100

        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%1d", hours, minutes, seconds, ms)
        } else {
            return String(format: "%02d:%02d:%1d", minutes, seconds, ms)
        }
    }
}

public extension Double {
    func formatMeters(withUnit: Bool) -> String {
        let result = String(Int(self))
        if withUnit {
            return result + " m"
        } else {
            return result
        }
    }

    func formatSecondsPerKm() -> String {
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}
